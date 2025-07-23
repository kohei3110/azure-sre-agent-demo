# Generate a unique suffix for resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create the main resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "rg-${var.project_name}-${var.environment_name}"
  location = var.location
  
  tags = merge(local.common_tags, {
    "azd-env-name" = var.environment_name
  })
}

# Define common tags
locals {
  common_tags = merge(var.tags, {
    Environment = var.environment_name
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })
  
  resource_suffix = random_string.suffix.result
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name != "" ? var.log_analytics_workspace_name : "log-${var.project_name}-${var.environment_name}-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.log_analytics_sku
  retention_in_days   = 90
  
  tags = local.common_tags
}

# Create Application Insights
resource "azurerm_application_insights" "main" {
  name                = var.application_insights_name != "" ? var.application_insights_name : "appi-${var.project_name}-${var.environment_name}-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  
  tags = local.common_tags
}

# Create Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.container_registry_name != "" ? var.container_registry_name : "acr${var.project_name}${var.environment_name}${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.container_registry_sku
  admin_enabled       = false  # Use managed identity instead
  
  tags = local.common_tags
}

# Create Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                = var.cosmos_db_account_name != "" ? var.cosmos_db_account_name : "cosmos-${var.project_name}-${var.environment_name}-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  
  # Serverless capacity mode for cost optimization
  capabilities {
    name = "EnableServerless"
  }
  
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  
  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
  
  # Enable backup
  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 168  # 7 days
    storage_redundancy  = "Local"
  }
  
  tags = local.common_tags
}

# Create Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = var.cosmos_db_database_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

# Create Cosmos DB SQL Container
resource "azurerm_cosmosdb_sql_container" "main" {
  name                = var.cosmos_db_container_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/id"]
  
  # Define indexing policy for performance optimization
  indexing_policy {
    indexing_mode = "consistent"
    
    included_path {
      path = "/*"
    }
    
    excluded_path {
      path = "/\"_etag\"/?"
    }
  }
}

# Create Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.project_name}-${var.environment_name}-${local.resource_suffix}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  tags = local.common_tags
}

# Create User-Assigned Managed Identity for Container Apps
resource "azurerm_user_assigned_identity" "container_app" {
  location            = azurerm_resource_group.main.location
  name                = "id-${var.project_name}-containerapp-${var.environment_name}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  
  tags = local.common_tags
}

# Grant ACR Pull permissions to the managed identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_app.principal_id
}

# Create Container App
resource "azurerm_container_app" "backend" {
  name                         = var.container_app_name != "" ? var.container_app_name : "ca-${var.project_name}-backend-${var.environment_name}-${local.resource_suffix}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app.id]
  }
  
  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.container_app.id
  }
  
  template {
    min_replicas = var.container_app_min_replicas
    max_replicas = var.container_app_max_replicas
    
    container {
      name   = "todo-backend"
      image  = var.container_image
      cpu    = var.container_app_cpu
      memory = var.container_app_memory
      
      env {
        name  = "AZURE_COSMOS_CONNECTION_STRING"
        value = azurerm_cosmosdb_account.main.connection_strings[0]
      }
      
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.main.connection_string
      }
      
      env {
        name  = "PORT"
        value = "8080"
      }
    }
  }
  
  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port               = 8080
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
  
  tags = local.common_tags
}

# Create Static Web App
resource "azurerm_static_site" "main" {
  name                = var.static_web_app_name != "" ? var.static_web_app_name : "stapp-${var.project_name}-${var.environment_name}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_tier           = var.static_web_app_sku
  sku_size           = var.static_web_app_sku
  
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "VITE_CONTAINER_APPS_URL"              = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
  }
  
  tags = local.common_tags
}

# Link Static Web App to Container App Backend
resource "azurerm_static_site_linked_backend" "main" {
  static_site_id  = azurerm_static_site.main.id
  backend_id      = azurerm_container_app.backend.id
}

# Create Load Testing resource
resource "azurerm_load_test" "main" {
  location            = azurerm_resource_group.main.location
  name                = var.load_testing_name != "" ? var.load_testing_name : "lt-${var.project_name}-${var.environment_name}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  
  tags = local.common_tags
}

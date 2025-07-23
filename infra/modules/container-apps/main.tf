# Create Container App
resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  
  # Configure managed identity if provided
  dynamic "identity" {
    for_each = var.managed_identity_id != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.managed_identity_id]
    }
  }
  
  # Configure container registry if provided
  dynamic "registry" {
    for_each = var.container_registry_server != null && var.managed_identity_id != null ? [1] : []
    content {
      server   = var.container_registry_server
      identity = var.managed_identity_id
    }
  }
  
  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    
    container {
      name   = "app"
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory
      
      # Configure environment variables
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
    }
  }
  
  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port               = var.target_port
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
  
  tags = var.tags
}

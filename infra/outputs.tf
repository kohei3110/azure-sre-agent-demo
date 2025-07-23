# Resource Group outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Static Web Apps outputs
output "static_web_app_name" {
  description = "The name of the Static Web App"
  value       = azurerm_static_site.main.name
}

output "static_web_app_hostname" {
  description = "The default hostname of the Static Web App"
  value       = azurerm_static_site.main.default_host_name
}

output "static_web_app_url" {
  description = "The URL of the Static Web App"
  value       = "https://${azurerm_static_site.main.default_host_name}"
}

output "static_web_app_api_key" {
  description = "The API key for the Static Web App"
  value       = azurerm_static_site.main.api_key
  sensitive   = true
}

# Container Apps outputs
output "container_app_name" {
  description = "The name of the Container App"
  value       = azurerm_container_app.backend.name
}

output "container_apps_fqdn" {
  description = "The FQDN of the Container App"
  value       = azurerm_container_app.backend.ingress[0].fqdn
}

output "container_apps_url" {
  description = "The URL of the Container App"
  value       = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
}

# Cosmos DB outputs
output "cosmos_db_account_name" {
  description = "The name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmos_db_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_connection_string" {
  description = "The connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.connection_strings[0]
  sensitive   = true
}

output "cosmos_db_database_name" {
  description = "The name of the Cosmos DB database"
  value       = azurerm_cosmosdb_sql_database.main.name
}

output "cosmos_db_container_name" {
  description = "The name of the Cosmos DB container"
  value       = azurerm_cosmosdb_sql_container.main.name
}

# Container Registry outputs
output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "The login server of the Container Registry"
  value       = azurerm_container_registry.main.login_server
}

# Application Insights outputs
output "application_insights_name" {
  description = "The name of Application Insights"
  value       = azurerm_application_insights.main.name
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string of Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

# Log Analytics outputs
output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

# Load Testing outputs
output "load_testing_name" {
  description = "The name of the Load Testing resource"
  value       = azurerm_load_test.main.name
}

output "load_testing_id" {
  description = "The ID of the Load Testing resource"
  value       = azurerm_load_test.main.id
}

# Managed Identity outputs
output "container_app_managed_identity_id" {
  description = "The ID of the Container App managed identity"
  value       = azurerm_user_assigned_identity.container_app.id
}

output "container_app_managed_identity_principal_id" {
  description = "The principal ID of the Container App managed identity"
  value       = azurerm_user_assigned_identity.container_app.principal_id
}

output "container_app_managed_identity_client_id" {
  description = "The client ID of the Container App managed identity"
  value       = azurerm_user_assigned_identity.container_app.client_id
}

# Environment variables for application configuration
output "environment_variables" {
  description = "Environment variables for application configuration"
  value = {
    VITE_CONTAINER_APPS_URL               = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
    AZURE_COSMOS_CONNECTION_STRING        = azurerm_cosmosdb_account.main.connection_strings[0]
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string
  }
  sensitive = true
}

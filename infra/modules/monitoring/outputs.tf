output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "application_insights_id" {
  description = "The ID of Application Insights"
  value       = azurerm_application_insights.main.id
}

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

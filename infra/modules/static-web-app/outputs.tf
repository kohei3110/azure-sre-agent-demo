output "id" {
  description = "The ID of the Static Web App"
  value       = azurerm_static_site.main.id
}

output "name" {
  description = "The name of the Static Web App"
  value       = azurerm_static_site.main.name
}

output "default_host_name" {
  description = "The default hostname of the Static Web App"
  value       = azurerm_static_site.main.default_host_name
}

output "url" {
  description = "The URL of the Static Web App"
  value       = "https://${azurerm_static_site.main.default_host_name}"
}

output "api_key" {
  description = "The API key for the Static Web App"
  value       = azurerm_static_site.main.api_key
  sensitive   = true
}

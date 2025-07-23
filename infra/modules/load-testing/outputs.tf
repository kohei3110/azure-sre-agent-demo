output "id" {
  description = "The ID of the Load Testing resource"
  value       = azurerm_load_test.main.id
}

output "name" {
  description = "The name of the Load Testing resource"
  value       = azurerm_load_test.main.name
}

output "data_plane_uri" {
  description = "The data plane URI of the Load Testing resource"
  value       = azurerm_load_test.main.dataplane_uri
}

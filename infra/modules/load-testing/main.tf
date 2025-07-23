# Create Load Testing resource
resource "azurerm_load_test" "main" {
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

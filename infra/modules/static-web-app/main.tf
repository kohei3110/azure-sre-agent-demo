# Create Static Web App
resource "azurerm_static_site" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier           = var.sku_tier
  sku_size           = var.sku_size
  
  app_settings = var.app_settings
  
  tags = var.tags
}

# Link Static Web App to Container App Backend (if provided)
resource "azurerm_static_site_linked_backend" "main" {
  count = var.container_app_backend_id != null ? 1 : 0
  
  static_site_id = azurerm_static_site.main.id
  backend_id     = var.container_app_backend_id
}

variable "name" {
  description = "The name of the Static Web App"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Static Web App will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sku_tier" {
  description = "The SKU tier of the Static Web App"
  type        = string
  default     = "Standard"
}

variable "sku_size" {
  description = "The SKU size of the Static Web App"
  type        = string
  default     = "Standard"
}

variable "app_settings" {
  description = "A map of app settings for the Static Web App"
  type        = map(string)
  default     = {}
}

variable "container_app_backend_id" {
  description = "The ID of the Container App to link as backend"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  type        = string
}

variable "application_insights_name" {
  description = "The name of Application Insights"
  type        = string
}

variable "location" {
  description = "The Azure Region where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "log_analytics_sku" {
  description = "The SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for logs in days"
  type        = number
  default     = 90
}

variable "application_type" {
  description = "The type of application for Application Insights"
  type        = string
  default     = "web"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

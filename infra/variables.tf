# Common variables
variable "environment_name" {
  description = "The name of the environment (e.g., demo, dev, prod)"
  type        = string
  default     = "demo"
}

variable "location" {
  description = "The Azure Region where all resources will be created"
  type        = string
  default     = "East US 2"
}

variable "resource_group_name" {
  description = "The name of the resource group to create all resources in"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "todo-app"
}

# Static Web Apps configuration
variable "static_web_app_name" {
  description = "The name of the Static Web App"
  type        = string
  default     = ""
}

variable "static_web_app_sku" {
  description = "The SKU of the Static Web App"
  type        = string
  default     = "Standard"
}

# Container Apps configuration
variable "container_app_name" {
  description = "The name of the Container App"
  type        = string
  default     = ""
}

variable "container_app_cpu" {
  description = "The CPU allocation for the Container App"
  type        = number
  default     = 0.25
}

variable "container_app_memory" {
  description = "The memory allocation for the Container App"
  type        = string
  default     = "0.5Gi"
}

variable "container_app_min_replicas" {
  description = "The minimum number of replicas for the Container App"
  type        = number
  default     = 0
}

variable "container_app_max_replicas" {
  description = "The maximum number of replicas for the Container App"
  type        = number
  default     = 10
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

# Cosmos DB configuration
variable "cosmos_db_account_name" {
  description = "The name of the Cosmos DB account"
  type        = string
  default     = ""
}

variable "cosmos_db_database_name" {
  description = "The name of the Cosmos DB database"
  type        = string
  default     = "TodoDB"
}

variable "cosmos_db_container_name" {
  description = "The name of the Cosmos DB container"
  type        = string
  default     = "TodoItems"
}

# Container Registry configuration
variable "container_registry_name" {
  description = "The name of the Container Registry"
  type        = string
  default     = ""
}

variable "container_registry_sku" {
  description = "The SKU of the Container Registry"
  type        = string
  default     = "Basic"
}

# Application Insights configuration
variable "application_insights_name" {
  description = "The name of Application Insights"
  type        = string
  default     = ""
}

# Log Analytics Workspace configuration
variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  type        = string
  default     = ""
}

variable "log_analytics_sku" {
  description = "The SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

# Load Testing configuration
variable "load_testing_name" {
  description = "The name of the Load Testing resource"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the Container App"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Container App will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  type        = string
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
}

variable "cpu" {
  description = "The CPU allocation for the Container App"
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "The memory allocation for the Container App"
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "The minimum number of replicas"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "The maximum number of replicas"
  type        = number
  default     = 10
}

variable "target_port" {
  description = "The target port for the container"
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "managed_identity_id" {
  description = "The ID of the managed identity to assign to the Container App"
  type        = string
  default     = null
}

variable "container_registry_server" {
  description = "The login server of the container registry"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

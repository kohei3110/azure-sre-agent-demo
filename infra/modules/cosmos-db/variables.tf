variable "account_name" {
  description = "The name of the Cosmos DB account"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Cosmos DB account will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "database_name" {
  description = "The name of the Cosmos DB database"
  type        = string
}

variable "container_name" {
  description = "The name of the Cosmos DB container"
  type        = string
}

variable "partition_key_paths" {
  description = "The partition key paths for the container"
  type        = list(string)
  default     = ["/id"]
}

variable "consistency_level" {
  description = "The consistency level for the Cosmos DB account"
  type        = string
  default     = "Session"
}

variable "backup_interval_in_minutes" {
  description = "The backup interval in minutes"
  type        = number
  default     = 240
}

variable "backup_retention_in_hours" {
  description = "The backup retention in hours"
  type        = number
  default     = 168
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

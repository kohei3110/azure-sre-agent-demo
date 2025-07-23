variable "name" {
  description = "The name of the Load Testing resource"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Load Testing resource will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

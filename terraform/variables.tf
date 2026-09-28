variable "location" {
  description = "Azure region used by the local Floci-AZ laboratory."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource Group used by the microservices laboratory."
  type        = string
  default     = "rg-microservices-local"
}
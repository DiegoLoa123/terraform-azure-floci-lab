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


# ============================================================
# Networking
# ============================================================

variable "vnet_name" {
  description = "Name of the Virtual Network used by the microservices laboratory."
  type        = string
  default     = "vnet-microservices-local"
}

variable "vnet_address_space" {
  description = "Address space assigned to the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "Name of the subnet reserved for AKS."
  type        = string
  default     = "subnet-aks"
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes assigned to the AKS subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "data_subnet_name" {
  description = "Name of the subnet reserved for data services."
  type        = string
  default     = "subnet-data"
}

variable "data_subnet_address_prefixes" {
  description = "Address prefixes assigned to the data subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}


# ============================================================
# Storage
# ============================================================

variable "storage_account_name" {
  description = "Name of the Storage Account used by the microservices laboratory."
  type        = string
  default     = "stmicroserviceslocal"
}

variable "storage_container_name" {
  description = "Name of the Blob Storage container."
  type        = string
  default     = "microservices"
}


# ============================================================
# Key Vault
# ============================================================

variable "key_vault_name" {
  description = "Name of the Key Vault used by the microservices laboratory."
  type        = string
  default     = "kv-microservices-local"
}
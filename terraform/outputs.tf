output "resource_group_name" {
  description = "Name of the local Resource Group."
  value       = azurerm_resource_group.microservices.name
}

output "resource_group_location" {
  description = "Location of the local Resource Group."
  value       = azurerm_resource_group.microservices.location
}

# ============================================================
# Networking
# ============================================================

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.microservices.name
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network."
  value       = azurerm_virtual_network.microservices.address_space
}

output "aks_subnet_name" {
  description = "Name of the AKS subnet."
  value       = azurerm_subnet.aks.name
}

output "data_subnet_name" {
  description = "Name of the data subnet."
  value       = azurerm_subnet.data.name
}

# ============================================================
# Key Vault
# ============================================================

output "key_vault_name" {
  description = "Name of the local Key Vault."
  value       = azurerm_key_vault.microservices.name
}

output "key_vault_uri" {
  description = "Local Key Vault data-plane URI returned by Floci-AZ."
  value       = azurerm_key_vault.microservices.vault_uri
}


# ============================================================
# Service Bus - Floci-AZ
# ============================================================

output "service_bus_queue_name" {
  description = "Name of the Service Bus queue."
  value       = var.service_bus_queue_name
}

output "service_bus_management_endpoint" {
  description = "Floci-AZ Service Bus management endpoint."
  value       = "http://127.0.0.1:4577/devstoreaccount1-servicebus"
}
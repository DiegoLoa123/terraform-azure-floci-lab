output "resource_group_name" {
  description = "Name of the local Resource Group."
  value       = azurerm_resource_group.microservices.name
}

output "resource_group_location" {
  description = "Location of the local Resource Group."
  value       = azurerm_resource_group.microservices.location
}


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
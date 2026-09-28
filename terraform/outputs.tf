output "resource_group_name" {
  description = "Name of the local Resource Group."
  value       = azurerm_resource_group.microservices.name
}

output "resource_group_location" {
  description = "Location of the local Resource Group."
  value       = azurerm_resource_group.microservices.location
}
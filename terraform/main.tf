resource "azurerm_resource_group" "microservices" {
  name     = var.resource_group_name
  location = var.location
}
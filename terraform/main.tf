resource "azurerm_resource_group" "microservices" {
  name     = var.resource_group_name
  location = var.location
}

# ============================================================
# Networking
# ============================================================

resource "azurerm_virtual_network" "microservices" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.microservices.location
  resource_group_name = azurerm_resource_group.microservices.name
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.microservices.name
  virtual_network_name = azurerm_virtual_network.microservices.name
  address_prefixes     = var.aks_subnet_address_prefixes
}

resource "azurerm_subnet" "data" {
  name                 = var.data_subnet_name
  resource_group_name  = azurerm_resource_group.microservices.name
  virtual_network_name = azurerm_virtual_network.microservices.name
  address_prefixes     = var.data_subnet_address_prefixes
}

# ============================================================
# Storage
# ============================================================

resource "azurerm_storage_account" "microservices" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.microservices.name
  location                 = azurerm_resource_group.microservices.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [
      queue_encryption_key_type,
      table_encryption_key_type,
      https_traffic_only_enabled,
      min_tls_version
    ]
  }
}

resource "azurerm_storage_container" "microservices" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.microservices.id
  container_access_type = "private"
}
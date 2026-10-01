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
  name                             = var.storage_account_name
  resource_group_name              = azurerm_resource_group.microservices.name
  location                         = azurerm_resource_group.microservices.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  cross_tenant_replication_enabled = false

  lifecycle {
    ignore_changes = [
      queue_encryption_key_type,
      table_encryption_key_type,
      enable_https_traffic_only,
      min_tls_version
    ]
  }
}

resource "azurerm_storage_container" "microservices" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.microservices.name
  container_access_type = "private"
}

# ============================================================
# Key Vault
# ============================================================

resource "azurerm_key_vault" "microservices" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.microservices.location
  resource_group_name = azurerm_resource_group.microservices.name

  tenant_id = "00000000-0000-0000-0000-000000000002"
  sku_name  = "standard"

  soft_delete_retention_days = 90
  purge_protection_enabled   = false
}


# ============================================================
# Service Bus - Floci-AZ
# ============================================================

resource "terraform_data" "service_bus_queue" {

  input = {
    endpoint   = "http://127.0.0.1:4577/devstoreaccount1-servicebus"
    queue_name = var.service_bus_queue_name
  }

  triggers_replace = [
    var.service_bus_queue_name
  ]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-NoProfile", "-Command"]

    command = <<-EOT
      Invoke-WebRequest `
        -Uri "${self.input.endpoint}/${self.input.queue_name}" `
        -Method PUT `
        -UseBasicParsing | Out-Null
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["PowerShell", "-NoProfile", "-Command"]

    command = <<-EOT
      Invoke-WebRequest `
        -Uri "${self.input.endpoint}/${self.input.queue_name}" `
        -Method DELETE `
        -UseBasicParsing | Out-Null
    EOT
  }
}


# ============================================================
# PostgreSQL Flexible Server - Floci-AZ
# ============================================================

resource "azurerm_postgresql_flexible_server" "microservices" {
  name                = var.postgresql_server_name
  resource_group_name = azurerm_resource_group.microservices.name
  location            = azurerm_resource_group.microservices.location

  version = var.postgresql_version

  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password

  storage_mb = 32768

  sku_name = "B_Standard_B1ms"
}
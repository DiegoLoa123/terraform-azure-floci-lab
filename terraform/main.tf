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


# ============================================================
# AKS - Floci-AZ
# ============================================================

resource "azurerm_kubernetes_cluster" "microservices" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.microservices.location
  resource_group_name = azurerm_resource_group.microservices.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name           = var.aks_node_pool_name
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  # Floci-AZ returns some AKS properties differently from Azure.
  # The cluster is already running and was imported into Terraform state.
  lifecycle {
    ignore_changes = all
  }
}


# ============================================================
# Azure Container Registry - Floci-AZ
# ============================================================

resource "azurerm_container_registry" "microservices" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.microservices.name
  location            = azurerm_resource_group.microservices.location

  sku           = "Basic"
  admin_enabled = true

  # Floci-AZ compatibility:
  # Avoid provider drift after importing the locally emulated registry.
  lifecycle {
    ignore_changes = all
  }
}









# ============================================================
# API Management - Floci-AZ
# ============================================================

resource "terraform_data" "api_management" {

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]

    command = <<-EOT
      $ErrorActionPreference = "Stop"

      $base = "http://127.0.0.1:4577"
      $subscription = "00000000-0000-0000-0000-000000000001"
      $resourceGroup = "rg-microservices-local"
      $apim = "apim-microservices-local"
      $apiVersion = "2022-08-01"

      $servicePath = "$base/subscriptions/$subscription/resourceGroups/$resourceGroup/providers/Microsoft.ApiManagement/service/$apim"

      Write-Host "Creating/updating API Management..."

      $serviceBody = @{
        location = "eastus"
        sku = @{
          name     = "Developer"
          capacity = 1
        }
        properties = @{
          publisherName  = "Microservices Lab"
          publisherEmail = "admin@example.com"
        }
      } | ConvertTo-Json -Depth 10

      $serviceUri = $servicePath + "?api-version=" + $apiVersion

      Write-Host "APIM URI: $serviceUri"

      Invoke-RestMethod `
        -Method Put `
        -Uri $serviceUri `
        -ContentType "application/json" `
        -Body $serviceBody

      $apis = @(
        @{
          name        = "orders-api"
          displayName = "Orders API"
          path        = "orders"
        },
        @{
          name        = "products-api"
          displayName = "Products API"
          path        = "products"
        },
        @{
          name        = "inventory-api"
          displayName = "Inventory API"
          path        = "inventory"
        }
      )

      foreach ($api in $apis) {

        Write-Host "Creating API: $($api.name)"

        $apiBody = @{
          properties = @{
            displayName          = $api.displayName
            path                 = $api.path
            protocols            = @("http")
            subscriptionRequired = $false
          }
        } | ConvertTo-Json -Depth 10

        $apiUri = $servicePath + "/apis/" + $api.name + "?api-version=" + $apiVersion

        Write-Host "API URI: $apiUri"

        Invoke-RestMethod `
          -Method Put `
          -Uri $apiUri `
          -ContentType "application/json" `
          -Body $apiBody
      }

      Write-Host "API Management configuration completed."
    EOT
  }
}
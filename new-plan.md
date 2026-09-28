Estoy migrando mi laboratorio Azure local desde Docker Compose con Floci-AZ hacia el uso directo de comandos `floci-az`.

Contexto del proyecto:
- SO: Windows
- Docker instalado
- Terraform instalado
- AzureRM provider: 4.81.0
- Proyecto:
  D:\CODE\Repos-Personales\terraform-floci-lab
- Infraestructura ya creada y estable con Terraform:
  - Resource Group: rg-microservices-local
  - VNet: vnet-microservices-local
  - subnet-aks: 10.0.1.0/24
  - subnet-data: 10.0.2.0/24
  - Storage Account: stmicroserviceslocal
  - Storage Container: microservices
- `terraform plan` llegó a:
  `No changes. Your infrastructure matches the configuration.`
- `terraform state list` contiene:
  azurerm_resource_group.microservices
  azurerm_storage_account.microservices
  azurerm_storage_container.microservices
  azurerm_subnet.aks
  azurerm_subnet.data
  azurerm_virtual_network.microservices

Problema actual:
- Quiero agregar Azure Service Bus:
  - namespace: sb-microservices-local
  - queue: order-created
- Terraform genera correctamente:
  `Plan: 2 to add, 0 to change, 0 to destroy`
- Pero `terraform apply` falla con:
  `404 ResourceNotFound`
  para:
  `Microsoft.ServiceBus/namespaces/sb-microservices-local`
- El HCL de Service Bus es válido.
- Floci recibe correctamente los GET/PUT en los logs.
- Las variables SERVICE_BUS estaban activadas correctamente en Docker.
- Por eso sospechamos de una limitación/incompatibilidad del modo Docker Compose/Floci ARM con Service Bus.

Objetivo nuevo:
1. Dejar Docker Compose.
2. Usar directamente los comandos oficiales de Floci/Floci-AZ.
3. Migrar sin destruir innecesariamente el proyecto Terraform.
4. Levantar Floci-AZ correctamente para Terraform.
5. Verificar Resource Group, VNet, Storage y luego Service Bus.
6. Mantener el proyecto como laboratorio/portafolio de Azure + Terraform.

---
Quiero que me guíes paso a paso, guiandome donde y que comandos usar (para que salga bien esta segunda ves, y mas aun que ya no usare docker), no hay problerma con destruir state porque todo es un entorno de prueba y no guarde nada, aunque no se si requieres el codigo que hice para la vnet, buss y resource group de mi anteriro proyecto, avisame porfa.
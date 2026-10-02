Terraform + Floci-AZ — Local Azure Infrastructure Lab
======================================================

STATUS: COMPLETED


FASE 1 — RESOURCE GROUP
-----------------------
[COMPLETED]

- rg-microservices-local


FASE 2 — NETWORKING
-------------------
[COMPLETED]

- Virtual Network
  - vnet-microservices-local
  - Address space: 10.0.0.0/16

- Subnets
  - subnet-aks
  - subnet-data


FASE 3 — STORAGE & SECURITY
---------------------------
[COMPLETED]

- Azure Storage Account
  - stmicroserviceslocal

- Blob Container
  - microservices

- Azure Key Vault
  - kv-microservices-local


FASE 4 — MESSAGING
------------------
[COMPLETED]

- Azure Service Bus
- Queue:
  - order-created

Nota de implementación:
Service Bus se gestiona mediante terraform_data y el punto de conexión REST local de Floci-AZ, debido a limitaciones de compatibilidad entre el emulador y el proveedor.


FASE 5 — DATABASE
-----------------
[COMPLETED]

- PostgreSQL Flexible Server
  - pg-microservices-local

- PostgreSQL runs locally through the Floci-AZ
  Docker-backed implementation.


FASE 6 — CONTAINER PLATFORM
---------------------------
[COMPLETED]


6A — AKS
~~~~~~~~
- aks-microservices-local
- Kubernetes environment backed locally by k3s
- Node status: Ready
~~~~~~~~


6B — AZURE CONTAINER REGISTRY
~~~~~~~~
- acrmicroserviceslocal
- Local registry backed by registry:2
~~~~~~~~


6C — KUBERNETES WORKLOADS
~~~~~~~~
Deployments:

- order-service
- product-service
- inventory-service

Each workload contains:

- Kubernetes Deployment
- 1 replica
- ClusterIP Service

Final status:

- order-service       1/1 Running
- product-service     1/1 Running
- inventory-service   1/1 Running
~~~~~~~~


FASE 7 — API MANAGEMENT
-----------------------
[COMPLETED]

API Management service:

- apim-microservices-local

Configured APIs:

- Orders API
  Path: /orders

- Products API
  Path: /products

- Inventory API
  Path: /inventory

API Management is provisioned through terraform_data
and the Floci-AZ ARM-compatible REST API.

This workaround avoids AzureRM provider calls to APIM
endpoints that are not implemented by the local emulator.


NOTAS DE COMPATIBILIDAD
===================

Floci-AZ emula servicios de Azure de forma local y no ofrece una paridad funcional completa con Microsoft Azure.
Durante la práctica de laboratorio, algunas diferencias entre el proveedor AzureRM de Terraform y Floci-AZ requirieron soluciones alternativas específicas:

1. AKS
    - El clúster de Kubernetes se creó correctamente mediante Floci-AZ utilizando k3s. 
    - El proceso de sondeo (*polling*) de Terraform no finalizó correctamente. 
    - El recurso existente se importó al estado de Terraform. 
    - Se ignora la divergencia (*drift*) del proveedor para este laboratorio local.

2. Azure Container Registry
    - ACR se creó correctamente utilizando registry:2. 
    - Las operaciones de sondeo y actualización de Terraform mostraron problemas de compatibilidad con el emulador. 
    - El recurso existente se importó al estado de Terraform. 
    - Se ignora la divergencia (*drift*) del proveedor para este laboratorio local.

3. Service Bus
    - Gestionado mediante terraform_data y la API REST local.

4. API Management
    - Gestionado mediante terraform_data y la API REST local compatible con ARM, ya que algunas configuraciones del portal consultadas por AzureRM no están implementadas en Floci-AZ.

Estas soluciones alternativas son específicas para el entorno de aprendizaje local y no pretenden servir como patrones de configuración para entornos de producción en Azure.


FINAL STATUS
============

Resource Group               COMPLETED
Networking                   COMPLETED
Storage                      COMPLETED
Key Vault                    COMPLETED
Service Bus                  COMPLETED
PostgreSQL                   COMPLETED
Azure Container Registry     COMPLETED
AKS / k3s                    COMPLETED
Kubernetes Workloads         COMPLETED
API Management               COMPLETED

LABORATORY COMPLETED.
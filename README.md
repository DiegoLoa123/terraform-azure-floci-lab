
### Arquitectura

RESOURCE GROUP
│
├── NETWORKING
│   ├── VNet
│   ├── subnet-aks
│   └── subnet-data
│
├── STORAGE
│   ├── Storage Account
│   └── Container
│
└── SERVICE BUS
    ├── Namespace
    └── Queue order-created



### Limitaciones
Actualmente, Floci-AZ no conserva ni actualiza correctamente las etiquetas de los grupos de recursos a través del proveedor AzureRM en este entorno.
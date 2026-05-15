resource "azurerm_resource_group" "main-rg" {
    name = "azure-k8s-devops-pipeline-rg"
    location = var.location
}

resource "azurerm_virtual_network" "vnet" {
    name = "azure-k8s-devops-pipeline-vnet"
    location = azurerm_resource_group.main-rg.location
    resource_group_name = azurerm_resource_group.main-rg.name
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
    name = "azure-k8s-devops-pipeline-subnet"
    resource_group_name = azurerm_resource_group.main-rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_container_registry" "acr" {
    name = "azurek8sdevopspipeline279"
    resource_group_name = azurerm_resource_group.main-rg.name
    location = azurerm_resource_group.main-rg.location
    sku = "Basic"
    admin_enabled = false
}

resource "azurerm_kubernetes_cluster" "aks" {
    name = "azure-k8s-devops-pipeline-aks"
    location = azurerm_resource_group.main-rg.location
    resource_group_name = azurerm_resource_group.main-rg.name
    dns_prefix = "azurek8sproject"

    oidc_issuer_enabled = true
    workload_identity_enabled = true

    default_node_pool {
      name = "default"
      vm_size = "Standard_B2s_v2"
      vnet_subnet_id = azurerm_subnet.subnet.id

      enable_auto_scaling = true
      node_count = 1
      min_count = 1
      max_count = 2
    }

    identity {
        type = "SystemAssigned"
    }

    network_profile {
        network_plugin = "azure"
        service_cidr = "172.16.0.0/16"
        dns_service_ip = "172.16.0.10"
    }
}

resource "azurerm_role_assignment" "role_assign" {
    principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    role_definition_name = "AcrPull"
    scope = azurerm_container_registry.acr.id
}
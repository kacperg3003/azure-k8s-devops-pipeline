output "resource_group_name" {
  value = azurerm_resource_group.main-rg.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_config_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main-rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

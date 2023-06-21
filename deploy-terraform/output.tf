output "rg_name" {
  value = azurerm_resource_group.rsg.name
}

output "aks_name" {
    value = azurerm_kubernetes_cluster.k8s.name
}

output "private_key" {
  value     = tls_private_key.ssh_key_generic_vm.private_key_pem
  sensitive = true
}

output "rg_name" {
  value = azurerm_resource_group.rsg.name
}

output "aks_name" {
    value = azurerm_kubernetes_cluster.k8s.name
}

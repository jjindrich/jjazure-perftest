output "private_key" {
  value     = tls_private_key.ssh_key_generic_vm.private_key_pem
  sensitive = true
}

output "haproxy_vm_id" {
    value = azurerm_linux_virtual_machine.haproxy_vm.id
}

output "acr_name" {
    value = var.acr_name
}

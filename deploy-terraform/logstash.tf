resource "azurerm_network_interface" "log_nic" {
  name                = "${var.log_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-monitor.name

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "logstash_vm" {
  name                  = var.log_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rsg-monitor.name
  network_interface_ids = [azurerm_network_interface.log_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.log_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.linux_vm_sku.publisher
    offer     = var.linux_vm_sku.offer
    sku       = var.linux_vm_sku.sku
    version   = var.linux_vm_sku.version
  }

  computer_name                   = "logstash"
  admin_username                  = var.vm_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_username
    public_key = tls_private_key.ssh_key_generic_vm.public_key_openssh
  }

  depends_on = [
    azurerm_network_interface_security_group_association.log_nic_nsg // fix for Operation 'startTenantUpdate' is not allowed on VM during destroy
  ]
}

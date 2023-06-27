resource "azurerm_network_interface" "rabbitmq_nic" {
  name                = "${var.rabbitmq_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "rabbitmq_vm" {
  name                  = var.rabbitmq_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rsg-svc.name
  network_interface_ids = [azurerm_network_interface.rabbitmq_nic.id]
  size                  = "Standard_D2d_v5"

  os_disk {
    name                 = "${var.rabbitmq_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.linux_vm_sku.publisher
    offer     = var.linux_vm_sku.offer
    sku       = var.linux_vm_sku.sku
    version   = var.linux_vm_sku.version
  }

  computer_name                   = "rabbitmq"
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key_generic_vm.public_key_openssh
  }
}

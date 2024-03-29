resource "azurerm_network_interface" "elastic_nic" {
  name                = "${var.elastic_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  enable_accelerated_networking = true
  
  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "elastic_vm" {
  name                  = var.elastic_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rsg-svc.name
  network_interface_ids = [azurerm_network_interface.elastic_nic.id]
  size                  = var.elastic_sku_size
  zone                  = var.vm_avzone

  os_disk {
    name                 = "${var.elastic_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.linux_vm_sku.publisher
    offer     = var.linux_vm_sku.offer
    sku       = var.linux_vm_sku.sku
    version   = var.linux_vm_sku.version
  }

  computer_name                   = "elastic"
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key_generic_vm.public_key_openssh
  }
}

resource "azurerm_managed_disk" "elastic_data" {
  name                 = "${var.elastic_name}-data"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rsg-svc.name
  storage_account_type = var.elastic_data_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.elastic_data_disk_size
  zone                 = var.vm_avzone
}

resource "azurerm_virtual_machine_data_disk_attachment" "elastic_data_attach" {
  managed_disk_id    = azurerm_managed_disk.elastic_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.elastic_vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

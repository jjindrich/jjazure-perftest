resource "azurerm_network_security_group" "grafana_nsg" {
  name                = "${var.grafana_name}-nsg"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  security_rule {
    name                       = "ALL"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "grafana_nic" {
  name                = "${var.grafana_name}-nic"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "grafana_nic_nsg" {
  network_interface_id      = azurerm_network_interface.grafana_nic.id
  network_security_group_id = azurerm_network_security_group.grafana_nsg.id
}

resource "azurerm_linux_virtual_machine" "grafana_vm" {
  name                  = var.grafana_name
  location              = azurerm_resource_group.rsg.location
  resource_group_name   = azurerm_resource_group.rsg.name
  network_interface_ids = [azurerm_network_interface.grafana_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "grafana-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "grafana"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key_generic_vm.public_key_openssh
  }
}

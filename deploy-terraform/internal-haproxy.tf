resource "azurerm_network_security_group" "haproxy_nsg" {
  name                = "${var.haproxy_name}-nsg"
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

//scaleset
resource "azurerm_linux_virtual_machine_scale_set" "haproxy" {
  name                = "${var.haproxy_name}-vmss"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  sku                             = "Standard_DS1_v2"
  instances                       = 2
  admin_username                  = "azureuser"
  disable_password_authentication = true

  upgrade_mode    = "Rolling"
  health_probe_id = azurerm_lb_probe.haproxy_probe.id

  rolling_upgrade_policy {
    max_batch_instance_percent              = 50
    max_unhealthy_instance_percent          = 100
    max_unhealthy_upgraded_instance_percent = 50
    pause_time_between_batches              = "PT2S"
  }

  // https://learn.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init#deploying-a-cloud-init-enabled-virtual-machine
  custom_data = base64encode(data.local_file.cloudinit.content)

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key_generic_vm.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "40"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  network_interface {
    name    = "nic"
    primary = true

    network_security_group_id = azurerm_network_security_group.haproxy_nsg.id

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = azurerm_subnet.app-subnet.id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.haproxy_backend.id
      ]

      application_gateway_backend_address_pool_ids = [
        one(azurerm_application_gateway.gateway.backend_address_pool[*].id)
      ]
    }
  }

  boot_diagnostics {
  }
}

data "local_file" "cloudinit" {
  filename = "${path.module}/scripts/cloudinit_haproxy.conf"
}

resource "azurerm_virtual_machine_scale_set_extension" "haproxy_perftest" {
  count = var.aks_perftest_ip != "" ? 1 : 0

  name                         = "ConfigureHAProxy"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.haproxy.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("${path.module}/scripts/update-haproxy.sh", {
  aks_lb_ip = "${var.aks_perftest_ip}"
}))}"
    }
SETTINGS
}

/*
// single nic
resource "azurerm_network_interface" "haproxy_nic" {
  name                = "${var.haproxy_name}-nic"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "haproxy_nic_nsg" {
  network_interface_id      = azurerm_network_interface.haproxy_nic.id
  network_security_group_id = azurerm_network_security_group.haproxy_nsg.id
}

resource "azurerm_linux_virtual_machine" "haproxy_vm" {
  name                  = var.haproxy_name
  location              = azurerm_resource_group.rsg.location
  resource_group_name   = azurerm_resource_group.rsg.name
  network_interface_ids = [azurerm_network_interface.haproxy_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "haproxy-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "40"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "haproxy"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key_generic_vm.public_key_openssh
  }
}

locals {
  encoded_script = base64encode(file("${path.module}/scripts/update-haproxy.sh"))
}

resource "azurerm_virtual_machine_extension" "haproxy_install" {
  name                 = "haproxy_setup"
  virtual_machine_id   = azurerm_linux_virtual_machine.haproxy_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "script": "${local.encoded_script}"
 }
SETTINGS
}
*/

// load balancer in front of HAProxy
resource "azurerm_public_ip" "haproxy_lb1" {
  name                = "${var.haproxy_lb_name}-pip"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "haproxy" {
  name                = var.haproxy_lb_name
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "ipconfig1"
    public_ip_address_id = azurerm_public_ip.haproxy_lb1.id
  }
}

resource "azurerm_lb_backend_address_pool" "haproxy_backend" {
  name            = "haproxy-backend"
  loadbalancer_id = azurerm_lb.haproxy.id
}

resource "azurerm_lb_probe" "haproxy_probe" {
  name            = "tcp-probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.haproxy.id
}

resource "azurerm_lb_rule" "rule1" {
  name                           = "rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.haproxy.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.haproxy_backend.id]
  probe_id                       = azurerm_lb_probe.haproxy_probe.id
  loadbalancer_id                = azurerm_lb.haproxy.id
}

resource "azurerm_network_interface_backend_address_pool_association" "haproxy_lb" {
  network_interface_id    = azurerm_network_interface.haproxy_nic.id
  ip_configuration_name   = azurerm_network_interface.haproxy_nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.haproxy_backend.id
}

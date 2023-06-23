resource "azurerm_network_security_group" "haproxy_nsg" {
  name                = "${var.haproxy_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-web.name

  security_rule {
    name                       = "InboundFromFrontDoor"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureFrontDoor.Backend"
    destination_address_prefix = "*"
  }
}

//scaleset
resource "azurerm_linux_virtual_machine_scale_set" "haproxy" {
  name                = "${var.haproxy_name}-vmss"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-web.name

  sku                             = "Standard_DS1_v2"
  instances                       = 2
  admin_username                  = var.vm_username
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
  custom_data = filebase64("${path.module}/scripts/cloudinit_haproxy.conf")

  admin_ssh_key {
    username   = var.vm_username
    public_key = tls_private_key.ssh_key_generic_vm.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "40"
  }

  source_image_reference {
    publisher = var.linux_vm_sku.publisher
    offer     = var.linux_vm_sku.offer
    sku       = var.linux_vm_sku.sku
    version   = var.linux_vm_sku.version
  }

  network_interface {
    name    = "nic"
    primary = true

    network_security_group_id = azurerm_network_security_group.haproxy_nsg.id

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = azurerm_subnet.web-subnet.id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.haproxy_backend.id
      ]
    }
  }

  boot_diagnostics {
  }

  extension {
    name                 = "ConfigureHAProxy"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("${path.module}/scripts/update-haproxy.sh", {
    aks_lb_ip = "${local.perftest_lb_ip}",
    fdid = "${azurerm_cdn_frontdoor_profile.fd.resource_guid}",
}))}"
    }
SETTINGS
}

depends_on = [
  azurerm_lb_rule.haproxy
]
}

// load balancer in front of HAProxy
resource "azurerm_public_ip" "haproxy_lb1" {
  name                = "${var.haproxy_lb_name}-pip"
  resource_group_name = azurerm_resource_group.rsg-web.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "haproxy" {
  name                = var.haproxy_lb_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-web.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "ipconfig1"
    public_ip_address_id = azurerm_public_ip.haproxy_lb1.id
  }
}

resource "azurerm_lb_backend_address_pool" "haproxy_backend" {
  name            = "backend-haproxy"
  loadbalancer_id = azurerm_lb.haproxy.id
}

resource "azurerm_lb_probe" "haproxy_probe" {
  name            = "tcp-probe-80"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.haproxy.id
}

resource "azurerm_lb_rule" "haproxy" {
  name                           = "rule-haproxy"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.haproxy.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.haproxy_backend.id]
  probe_id                       = azurerm_lb_probe.haproxy_probe.id
  loadbalancer_id                = azurerm_lb.haproxy.id
}

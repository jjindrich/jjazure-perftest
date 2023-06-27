resource "azurerm_public_ip" "bastion" {
  count = var.bastion_deploy ? 1 : 0

  name                = "${var.bastion_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet" "bastion-subnet" {
  count = var.bastion_deploy ? 1 : 0

  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rsg-network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

resource "azurerm_network_security_group" "nsg_bastion" {
  count = var.bastion_deploy ? 1 : 0

  name                = "${var.vnet_name}-AzureBastionSubnet-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name

  // https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg
  security_rule {
    name                       = "AllowHttpsInbound"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"
    direction                  = "Inbound"
    priority                   = 1000
  }

  security_rule {
    name                       = "AllowGatewayManagerInbound"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 1100
    direction                  = "Inbound"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 1300
    direction                  = "Inbound"
  }
  security_rule {
    name                       = "AllowBastionHostCommunication"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 1200
    direction                  = "Inbound"
    destination_port_ranges = [
      "8080",
      "5701",
    ]
  }
  security_rule {
    name                       = "AllowSshRdpOutbound"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    access                     = "Allow"
    priority                   = 200
    direction                  = "Outbound"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges = [
      "3389",
      "22",
    ]
  }
  security_rule {
    name                       = "AllowAzureCloudOutbound"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
    access                     = "Allow"
    priority                   = 210
    direction                  = "Outbound"
  }
  security_rule {
    name                       = "AllowBastionCommunication"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = 220
    direction                  = "Outbound"
    destination_port_ranges = [
      "8080",
      "5701",
    ]
  }

  security_rule {
    name                       = "AllowHttpOutbound"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
    access                     = "Allow"
    priority                   = 2300
    direction                  = "Outbound"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  count = var.bastion_deploy ? 1 : 0
  
  subnet_id                 = azurerm_subnet.bastion-subnet[0].id
  network_security_group_id = azurerm_network_security_group.nsg_bastion[0].id
}

resource "azurerm_bastion_host" "bastion" {
  count = var.bastion_deploy ? 1 : 0

  name                = var.bastion_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

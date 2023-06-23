resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = var.location
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rsg-network.name
}

resource "azurerm_subnet" "web-subnet" {
    name                 = var.web_subnet
    address_prefixes     = [var.web_subnet_cidr]
    resource_group_name  = azurerm_resource_group.rsg-network.name
    virtual_network_name = azurerm_virtual_network.vnet.name
}
resource "azurerm_subnet" "app-subnet" {
    name                 = var.app_subnet
    address_prefixes     = [var.app_subnet_cidr]
    resource_group_name  = azurerm_resource_group.rsg-network.name
    virtual_network_name = azurerm_virtual_network.vnet.name
}
resource "azurerm_subnet" "db-subnet" {
  name                 = var.db_subnet
  address_prefixes     = [var.db_subnet_cidr]
  resource_group_name  = azurerm_resource_group.rsg-network.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  delegation {
    name      = "dlg-database"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.DBforMySQL/flexibleServers"
    }
  }
}
resource "azurerm_subnet" "virtual-subnet" {
  name                 = var.virtual_subnet
  address_prefixes     = [var.virtual_subnet_cidr]
  resource_group_name  = azurerm_resource_group.rsg-network.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_security_group" "nsg_web" {
  name                = "${var.vnet_name}-${var.web_subnet}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name    

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
resource "azurerm_subnet_network_security_group_association" "web_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.web-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}

resource "azurerm_network_security_group" "nsg_app" {
  name                = "${var.vnet_name}-${var.app_subnet}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name  
}
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.app-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

resource "azurerm_network_security_group" "nsg_db" {
  name                = "${var.vnet_name}-${var.db_subnet}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name  
}
resource "azurerm_subnet_network_security_group_association" "db_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.db-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_network_security_group" "nsg_virtual" {
  name                = "${var.vnet_name}-${var.virtual_subnet}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name  
}
resource "azurerm_subnet_network_security_group_association" "virtual_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.virtual-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_virtual.id
}
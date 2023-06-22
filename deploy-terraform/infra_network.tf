resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = var.location
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rsg-network.name
}
resource "azurerm_subnet" "web-subnet" {
    name                 = var.web_subnet
    resource_group_name  = azurerm_resource_group.rsg-network.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.web_subnet_cidr]
}
resource "azurerm_subnet" "app-subnet" {
    name                 = var.app_subnet
    resource_group_name  = azurerm_resource_group.rsg-network.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.app_subnet_cidr]
}

resource "azurerm_subnet" "elasticache-subnet" {
    name                 = var.elas_subnet  
    resource_group_name  = azurerm_resource_group.rsg-network.name        
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.elas_subnet_cidr]
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

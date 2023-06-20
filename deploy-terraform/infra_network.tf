resource "azurerm_resource_group" "rsg" {
  name     = var.rg_name
  location = var.rg_location
  tags     = var.tags
}

resource "azurerm_public_ip" "nat01" {
  name                = "natgw-pip"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat" {
  name                = "natgw"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat01" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat01.id
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rsg.location
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rsg.name
}

resource "azurerm_subnet" "app-subnet" {
    name                 = var.app_subnet
    resource_group_name  = azurerm_resource_group.rsg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.app_subnet_cidr]
}

resource "azurerm_subnet_nat_gateway_association" "app" {
  subnet_id      = azurerm_subnet.app-subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet" "elasticache-subnet" {
    name                 = var.elas_subnet  
    resource_group_name  = azurerm_resource_group.rsg.name        
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.elas_subnet_cidr]
}

resource "azurerm_subnet" "db-subnet" {
  name                 = var.db_subnet
  address_prefixes     = [var.db_subnet_cidr]
  resource_group_name  = azurerm_resource_group.rsg.name
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
  resource_group_name  = azurerm_resource_group.rsg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "appgw-subnet" {
    name                 = var.appgw_subnet  
    resource_group_name  = azurerm_resource_group.rsg.name        
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.appgw_subnet_cidr]
}

resource "azurerm_public_ip" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  name                = "bastion-pip"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet" "bastion-subnet" {
    name                 = "AzureBastionSubnet"  
    resource_group_name  = azurerm_resource_group.rsg.name        
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.bastion_subnet_cidr]
}

resource "azurerm_bastion_host" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  name                = "bastion"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

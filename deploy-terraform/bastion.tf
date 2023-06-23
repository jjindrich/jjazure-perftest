resource "azurerm_public_ip" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  name                = "${var.bastion_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_subnet" "bastion-subnet" {
  count = var.deploy_bastion ? 1 : 0

  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rsg-network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_cidr]
}
// TODO: NSG Bastion https://learn.microsoft.com/en-us/azure/bastion/bastion-nsg

resource "azurerm_bastion_host" "bastion" {
  count = var.deploy_bastion ? 1 : 0

  name                = var.bastion_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-network.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

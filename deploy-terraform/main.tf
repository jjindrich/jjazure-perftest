resource "azurerm_resource_group" "rsg" {
  name     = var.rg_name
  location = var.rg_location
}

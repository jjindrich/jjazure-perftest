resource "azurerm_resource_group" "rsg-network" {
  name     = var.rg-network_name
  location = var.location
}

resource "azurerm_resource_group" "rsg-monitor" {
  name     = var.rg-monitor_name
  location = var.location
}

resource "azurerm_resource_group" "rsg-web" {
  name     = var.rg-web_name
  location = var.location
}

resource "azurerm_resource_group" "rsg-app" {
  name     = var.rg-app_name
  location = var.location
}

resource "azurerm_resource_group" "rsg-data-db" {
  name     = var.rg-data-db_name
  location = var.location
}

resource "azurerm_resource_group" "rsg-data-svc" {
  name     = var.rg-data-svc_name
  location = var.location
}
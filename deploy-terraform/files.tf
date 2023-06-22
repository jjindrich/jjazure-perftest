resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_acc_name
  resource_group_name      = azurerm_resource_group.rsg-app.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "storage_share" {
  name                 = var.storage_share_name
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 50

  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
    }
  }
}

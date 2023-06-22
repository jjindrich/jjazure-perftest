resource "tls_private_key" "ssh_key_generic_vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// save SSH key to Key vault (useful with Bastion)
resource "azurerm_key_vault_secret" "ssh" {
  name         = "ssh-key"
  value        = tls_private_key.ssh_key_generic_vm.private_key_pem
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [ 
    azurerm_role_assignment.kv_current 
  ]
}

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rsg.location
  resource_group_name         = azurerm_resource_group.rsg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "azurerm_role_assignment" "kv_current" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

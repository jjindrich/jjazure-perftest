resource "tls_private_key" "ssh_key_generic_vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// save it to key vault (for Bastion Access)
resource "azurerm_key_vault_secret" "ssh" {
  name         = "ssh-key"
  value        = tls_private_key.ssh_key_generic_vm.private_key_pem
  key_vault_id = azurerm_key_vault.main.id
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

resource "azurerm_user_assigned_identity" "appgw" {
  location            = azurerm_resource_group.rsg.location
  name                = "mi-ssl"
  resource_group_name = azurerm_resource_group.rsg.name
}

resource "azurerm_role_assignment" "appgw_kv_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.appgw.principal_id
}

resource "azurerm_role_assignment" "kv_current_certificates" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_current_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}


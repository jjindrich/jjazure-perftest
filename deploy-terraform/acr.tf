resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  sku                 = "Basic"
  admin_enabled       = false

  provisioner "local-exec" {
    command = "az acr build -t perftest:v2 -r ${var.acr_name} https://github.com/jjindrich/jjazure-perftest.git -f PerfTest\\Dockerfile --platform linux"
  }
}

resource "azurerm_role_assignment" "role_for_acr" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# ACR default system scope maps
data "azurerm_container_registry_scope_map" "pull" {
  name                    = "_repositories_pull"
  resource_group_name     = azurerm_resource_group.rsg.name
  container_registry_name = azurerm_container_registry.acr.name
}

resource "azurerm_container_registry_token" "aks" {
  name                    = "aks-pull"
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = azurerm_resource_group.rsg.name
  scope_map_id            = data.azurerm_container_registry_scope_map.pull.id
}

resource "azurerm_container_registry_token_password" "aks" {
  container_registry_token_id = azurerm_container_registry_token.aks.id

  password1 {
  }
}

output "acr_token_name" {
  value = azurerm_container_registry_token.aks.name
}

output "acr_token_password" {
  value     = azurerm_container_registry_token_password.aks.password1[0].value
  sensitive = true
}

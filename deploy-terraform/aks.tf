resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-app.name
  dns_prefix          = "dns"
  kubernetes_version  = "1.26"

  default_node_pool {
    name                = "agentpool"
    node_count          = var.aks_nodecount
    min_count           = var.aks_node_min_size
    max_count           = var.aks_node_max_size
    enable_auto_scaling = true
    vm_size             = var.aks_vm_size
    vnet_subnet_id      = azurerm_subnet.app-subnet.id
    type                = "VirtualMachineScaleSets"
    zones               = var.aks_avzones
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = tls_private_key.ssh_key_generic_vm.public_key_openssh
    }
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    service_cidr      = "10.0.20.0/24"
    dns_service_ip    = "10.0.20.100"
  }

  aci_connector_linux {
    subnet_name = azurerm_subnet.virtual-subnet.name
  }

  lifecycle {
    ignore_changes = [
        default_node_pool.0.node_count
        ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "k8s-pool2" {
  name                  = "pool2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = var.aks_pool2_vm_size
  enable_auto_scaling   = true
  node_count            = var.aks_pool2_nodecount
  min_count             = var.aks_pool2_node_min_size
  max_count             = var.aks_pool2_node_max_size
  vnet_subnet_id        = azurerm_subnet.app-subnet.id
  zones                 = var.aks_avzones
  depends_on            = [azurerm_kubernetes_cluster.k8s]
}

resource "azurerm_role_assignment" "role_for_aci" {
  scope                = azurerm_subnet.virtual-subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.aci_connector_linux[0].connector_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_subnet_cluster_ingress" {
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_subnet.app-subnet.id
}

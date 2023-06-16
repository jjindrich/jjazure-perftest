resource "azurerm_kubernetes_cluster" "k8s" {
  name                	= var.k8s_name
  location            	= azurerm_resource_group.rsg.location
  resource_group_name 	= azurerm_resource_group.rsg.name
  dns_prefix          	= "dns"

  default_node_pool {
    name       		= "agentpool"
    node_count 		= var.k8s_nodecount
    vm_size    		= "Standard_D2_v2"
    vnet_subnet_id  	= azurerm_subnet.app-subnet.id
    type            	= "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = tls_private_key.ssh_key_generic_vm.public_key_openssh
    }
  }

  network_profile {
    network_plugin    	= "azure"
    network_policy    	= "azure"
    load_balancer_sku 	= "standard"
    service_cidr 	= "10.0.20.0/24"
    dns_service_ip 	= "10.0.20.100"
  }

  aci_connector_linux {
    subnet_name    = azurerm_subnet.virtual-subnet.name
  }
}

resource "azurerm_role_assignment" "role_for_aci" {
  scope                = azurerm_subnet.virtual-subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.aci_connector_linux[0].connector_identity[0].object_id
}

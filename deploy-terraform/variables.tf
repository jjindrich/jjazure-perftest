variable "location" {
  description = "Location"
  default     = "northeurope"
}

variable "bastion_deploy" {
  type    = bool
  default = false
}
variable "bastion_name" {
  description = "name of bastion"
  default     = "prft-bastion"
}

variable "rg-network_name" {
  description = "name of rg"
  default     = "prft-network-rg"
}
variable "rg-monitor_name" {
  description = "name of rg"
  default     = "prft-monitor-rg"
}
variable "rg-web_name" {
  description = "name of rg"
  default     = "prft-web-rg"
}
variable "rg-app_name" {
  description = "name of rg"
  default     = "prft-app-rg"
}
variable "rg-data_name" {
  description = "name of rg"
  default     = "prft-data-rg"
}
variable "rg-svc_name" {
  description = "name of rg"
  default     = "prft-svc-rg"
}

// --------------------------------------------
// NETWORK
variable "key_vault_name" {
  description = "Key Vault for certificates"
  default     = "prft-kv12345"
}

variable "vnet_name" {
  description = "Virtual Network Name"
  default     = "prft-vnet"
}

variable "vnet_address_space" {
  description = "CIDR Block of the VNet"
  default     = "10.0.0.0/16"
}

variable "web_subnet" {
  description = "name of web Subnet"
  default     = "web-snet"
}

variable "app_subnet" {
  description = "name of app Subnet"
  default     = "app-snet"
}

variable "db_subnet" {
  description = "name of db Subnet"
  default     = "db-snet"
}

variable "elas_subnet" {
  description = "name of elasticache Subnet"
  default     = "elk-snet"
}
variable "virtual_subnet" {
  description = "name of virtual Subnet (aks virtual node)"
  default     = "virtual-snet"
}

variable "web_subnet_cidr" {
  description = "cidr for web Subnet"
  default     = "10.0.1.0/24"
}

variable "app_subnet_cidr" {
  description = "cidr for app Subnet"
  default     = "10.0.2.0/24"
}

variable "db_subnet_cidr" {
  description = "cidr for db Subnet"
  default     = "10.0.4.0/24"
}

variable "elas_subnet_cidr" {
  description = "cidr for db Subnet"
  default     = "10.0.31.0/24"
}

variable "virtual_subnet_cidr" {
  description = "cidr for db Subnet"
  default     = "10.0.10.0/24"
}

variable "bastion_subnet_cidr" {
  description = "subnet for Bastion jump server"
  default     = "10.0.6.0/24"
}

// --------------------------------------------
// Availability Zones
variable "vm_avzone" {
  default     = "2"
}
variable "vmss_avzones" {
  default     = ["2"]
}
variable "aks_avzones" {
  default     = ["2"]
}
variable "db_avzone" {
  default     = "2"
}
variable "redis_avzones" {
  default     = ["2"]
}

// --------------------------------------------
// WEB
variable "haproxy_lb_name" {
  default = "prft-haproxy-lb"
}

variable "haproxy_vm_size" {
  default = "Standard_F4s_v2"
}

variable "haproxy_instances_count" {
  default = "1"
}

variable "haproxy_instances_min_count" {
  default = "1"
}

variable "haproxy_instances_max_count" {
  default = "3"
}

variable "ingress_hostname" {
  description = "DNS name for ingress (self-signed certificate)"
  default     = "test.com"
}
variable "front_door_name" {
  type    = string
  default = "prft-fd"
}

variable "front_door_endpoint_name" {
  type    = string
  default = "prftfd"
}

variable "front_door_sku_name" {
  type    = string
  default = "Standard_AzureFrontDoor"
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku_name)
    error_message = "The SKU value must be Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

// --------------------------------------------
// APP
variable "admin_username" {
  description = "VM username"
  default     = "azureuser"
}

variable "rabbitmq_name" {
  description = "VM name for rabbitmq"
  default     = "prft-rabbitmq-vm"
}

variable "log_name" {
  description = "VM name for logstash"
  default     = "prft-logstash-vm"
}

variable "grafana_name" {
  description = "VM name for grafana"
  default     = "prft-grafana-vm"
}

variable "elastic_name" {
  description = "VM name for elasticsearch"
  default     = "prft-elastic-vm"
}

variable "elastic_sku_size" {
  description = "VM name for elasticsearch"
  default     = "Standard_D2s_v3"
}

variable "elastic_data_storage_account_type" {
  description = "Storage type data disk for elasticsearch"
  default     = "Standard_LRS"
}

variable "elastic_data_disk_size" {
  description = "Storage size data disk for elasticsearch"
  default     = "10"
}

variable "haproxy_name" {
  description = "VM name for internal haproxy"
  default     = "prft-haproxy-vm"
}

variable "linux_vm_sku" {
  type = object({
    publisher = string,
    offer     = string,
    sku       = string,
    version   = string,
  })

  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}


variable "storage_acc_name" {
  description = "Storage account name"
  default     = "prftst12345"
}

variable "storage_share_name" {
  description = "Azure files share name"
  default     = "storage-share"
}

variable "aks_name" {
  description = "Kubernetes cluster name"
  default     = "prft-aks"
}

variable "aks_vm_size" {
  default = "Standard_D2_v2"
}

variable "aks_nodecount" {
  description = "Kubernetes number of nodes"
  default     = "1"
}

variable "aks_node_min_size" {
  description = "Kubernetes min number of nodes"
  default     = "1"
}

variable "aks_node_max_size" {
  description = "Kubernetes max number of nodes"
  default     = "3"
}

variable "aks_pool2_vm_size" {
  default = "Standard_D2_v2"
}

variable "aks_pool2_nodecount" {
  description = "Kubernetes number of nodes"
  default     = "1"
}

variable "aks_pool2_node_min_size" {
  description = "Kubernetes min number of nodes"
  default     = "1"
}

variable "aks_pool2_node_max_size" {
  description = "Kubernetes max number of nodes"
  default     = "3"
}

variable "acr_name" {
  description = "Name of the Container Registry"
  default     = "prftacr12345"
}

// --------------------------------------------
// DB + SVC
variable "dns_db_zone" {
  default = "db.private"
}

variable "mysql_name_prefix" {
  description = "MySQL prefix in name"
  type        = string
  default     = "prft"
}

variable "mysql_sku_name" {
  description = "MySQL sku name"
  type        = string
  default     = "B_Standard_B1s"
}

variable "mysql_allocated_storage" {
  description = "MySQL allocated storage"
  type        = number
  default     = 20
}

variable "mysql_iops_storage" {
  description = "MySQL iops storage"
  type        = number
  default     = 360
}

variable "mysql_administrator_password" {
  description = "MySQL administrator password"
  type        = string
  default     = ""
}

variable "mysql_onair_sku_name" {
  description = "MySQL onair sku name"
  type        = string
  default     = "B_Standard_B1s"
}

variable "mysql_onair_allocated_storage" {
  description = "MySQL onair allocated storage"
  type        = number
  default     = 20
}

variable "mysql_onair_iops_storage" {
  description = "MySQL onair iops storage"
  type        = number
  default     = 360
}

variable "mysql_onair_administrator_password" {
  description = "MySQL onair administrator password"
  type        = string
  default     = ""
}

variable "mysql_remp_sku_name" {
  description = "MySQL remp sku name"
  type        = string
  default     = "B_Standard_B1s"
}

variable "mysql_remp_allocated_storage" {
  description = "MySQL remp allocated storage"
  type        = number
  default     = 20
}

variable "mysql_remp_iops_storage" {
  description = "MySQL remp iops storage"
  type        = number
  default     = 360
}

variable "mysql_remp_administrator_password" {
  description = "MySQL remp administrator password"
  type        = string
  default     = ""
}

variable "mysql_contento_sku_name" {
  description = "MySQL contento sku name"
  type        = string
  default     = "B_Standard_B1s"
}

variable "mysql_contento_allocated_storage" {
  description = "MySQL contento allocated storage"
  type        = number
  default     = 20
}

variable "mysql_contento_iops_storage" {
  description = "MySQL contento iops storage"
  type        = number
  default     = 390
}

variable "mysql_contento_administrator_password" {
  description = "MySQL contento administrator password"
  type        = string
  default     = ""
}

variable "redis_name_prefix" {
  description = "Redis prefix in name"
  type        = string
  default     = "prft"
}

variable "redis_contento_capacity" {
  description = "Redis contento capacity name"
  type        = string
  default     = "1"
}

variable "redis_contento_family" {
  description = "Redis contento family name"
  type        = string
  default     = "C"
}

variable "redis_contento_sku_name" {
  description = "Redis contento sku name"
  type        = string
  default     = "Standard"
}

variable "redis_api_capacity" {
  description = "Redis api capacity name"
  type        = string
  default     = "1"
}

variable "redis_api_family" {
  description = "Redis api family name"
  type        = string
  default     = "C"
}

variable "redis_api_sku_name" {
  description = "Redis api sku name"
  type        = string
  default     = "Standard"
}

variable "redis_sessions_capacity" {
  description = "Redis sessions capacity name"
  type        = string
  default     = "1"
}

variable "redis_sessions_family" {
  description = "Redis sessions family name"
  type        = string
  default     = "C"
}

variable "redis_sessions_sku_name" {
  description = "Redis sessions sku name"
  type        = string
  default     = "Standard"
}

variable "redis_crm_capacity" {
  description = "Redis crm capacity name"
  type        = string
  default     = "1"
}

variable "redis_crm_family" {
  description = "Redis crm family name"
  type        = string
  default     = "C"
}

variable "redis_crm_sku_name" {
  description = "Redis crm sku name"
  type        = string
  default     = "Standard"
}
variable "location" {
  description = "Location"
  default     = "northeurope"
}

variable "deploy_bastion" {
  type    = bool
  default = false
}

variable "rg-network_name" {
  description = "name of rg"
  default     = "perftest-network-rg"
}
variable "rg-monitor_name" {
  description = "name of rg"
  default     = "perftest-monitor-rg"
}
variable "rg-web_name" {
  description = "name of rg"
  default     = "perftest-web-rg"
}
variable "rg-app_name" {
  description = "name of rg"
  default     = "perftest-app-rg"
}
variable "rg-data-db_name" {
  description = "name of rg"
  default     = "perftest-data-db-rg"
}
variable "rg-data-svc_name" {
  description = "name of rg"
  default     = "perftest-data-svc-rg"
}


variable "vnet_name" {
  description = "Virtual Network Name"
  default     = "perftest-vnet"
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
  default     = "svc-snet"
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

variable "rabbitmq_name" {
  description = "VM name for rabbitmq"
  default     = "rabbitmq-vm"
}

variable "log_name" {
  description = "VM name for logstash"
  default     = "logstash-vm"
}

variable "grafana_name" {
  description = "VM name for grafana"
  default     = "grafana-vm"
}

variable "elastic_name" {
  description = "VM name for elasticsearch"
  default     = "elastic-vm"
}

variable "haproxy_name" {
  description = "VM name for internal haproxy"
  default     = "haproxy-vm"
}

variable "storage_acc_name" {
  description = "Storage account name"
  default     = "perftestst"
}

variable "storage_share_name" {
  description = "Azure files share name"
  default     = "storage-share"
}

variable "k8s_name" {
  description = "Kubernetes cluster name"
  default     = "perftest-aks"
}

variable "k8s_nodecount" {
  description = "Kubernetes number of nodes"
  default     = "1"
}

variable "key_vault_name" {
  description = "Key Vault for certificates"
  default     = "perftest-kv"
}

variable "ingress_hostname" {
  description = "DNS name for ingress (self-signed certificate)"
  default     = "test.com"
}

variable "acr_name" {
  description = "Name of the Container Registry"
  default     = "perftestacr12345"
}

variable "haproxy_lb_name" {
  default = "lb-haproxy"
}

variable "aks_vm_size" {
  default = "Standard_D2_v2"
}

variable "front_door_name" {
  type    = string
  default = "perftest-fd"
}

variable "front_door_sku_name" {
  type    = string
  default = "Standard_AzureFrontDoor"
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.front_door_sku_name)
    error_message = "The SKU value must be Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "dns_db_zone" {
  default = "perfazure"
}

variable "mysql_allocated_storage" {
  description = "MySQL allocated storage"
  type        = number
  default     = 20
}

variable "mysql_administrator_password" {
  description = "MySQL administrator password"
  type        = string
  default     = ""
}

variable "mysql_onair_allocated_storage" {
  description = "MySQL onair allocated storage"
  type        = number
  default     = 20
}

variable "mysql_onair_administrator_password" {
  description = "MySQL onair administrator password"
  type        = string
  default     = ""
}

variable "mysql_remp_allocated_storage" {
  description = "MySQL remp allocated storage"
  type        = number
  default     = 20
}

variable "mysql_remp_administrator_password" {
  description = "MySQL remp administrator password"
  type        = string
  default     = ""
}

variable "mysql_contento_allocated_storage" {
  description = "MySQL contento allocated storage"
  type        = number
  default     = 20
}

variable "mysql_contento_administrator_password" {
  description = "MySQL contento administrator password"
  type        = string
  default     = ""
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

variable "rg_name" {
  description = "name of rg"
  default     = "perftest"
}

variable "rg_location" {
  description = "Location"
  default     = "northeurope"
}

variable "vnet_name" {
  description = "Virtual Network Name"
  default     = "vnet"
}

variable "vnet_address_space" {
  description = "CIDR Block of the VNet"
  default     = "10.0.0.0/16"
}

variable "app_subnet" {
  description = "name of app Subnet"
  default     = "app-subnet"
}

variable "db_subnet" {
  description = "name of db Subnet"
  default     = "db-subnet"
}

variable "elas_subnet" {
  description = "name of elasticache Subnet"
  default     = "elas-subnet"
}

variable "appgw_subnet" {
  default = "appgw-subnet"
}

variable "virtual_subnet" {
  description = "name of virtual Subnet (aks virtual node)"
  default     = "virtual-subnet"
}

variable "app_subnet_cidr" {
  description = "cidr for app Subnet"
  default     = "10.0.1.0/24"
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

variable "appgw_subnet_cidr" {
  description = "subnet for application gateway instances"
  default     = "10.0.5.0/24"
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
  default     = "fdstorageaccount1432"
}

variable "storage_share_name" {
  description = "Azure files share name"
  default     = "storage-share"
}

variable "k8s_name" {
  description = "Kubernetes cluster name"
  default     = "testing-k8s"
}

variable "k8s_nodecount" {
  description = "Kubernetes number of nodes"
  default     = "1"
}

variable "key_vault_name" {
  description = "Key Vault for certificates"
  default     = "kv-testing-1432"
}

variable "ingress_hostname" {
  description = "DNS name for ingress (self-signed certificate)"
  default     = "test.com"
}

variable "appgw_name" {
  description = "Instance name of application gateway"
  default     = "testing-appgw"
}

variable "appgw_scale_min" {
  description = "minimum number of instances we need (only when autoscaling is enabled)"
  default     = 0
}

variable "appgw_scale_max" {
  description = "if set, what maximum number of instances we allow (zero means no scaling)"
  default     = 0
}

variable "acr_name" {
  description = "Name of the Container Registry"
  default     = "testingacr1432"
}

variable "deploy_bastion" {
  type    = bool
  default = false
}

variable "haproxy_lb_name" {
  default = "lb-haproxy"
}

variable "aks_vm_size" {
  default = "Standard_D2_v2"
}

variable "front_door_name" {
  type    = string
  default = "fd"
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
  default = "novaazure"
}

variable "mysql_voyo_allocated_storage" {
  description = "MySQL voyo allocated storage"
  type        = number
  default     = 20
}

variable "mysql_voyo_administrator_password" {
  description = "MySQL voyo administrator password"
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

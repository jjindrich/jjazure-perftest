variable "tags" {
  description = "resource tags"
  default     = {}
}

variable "rg_name" {
  description = "name of rg"
  default     = "placeholder2"
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




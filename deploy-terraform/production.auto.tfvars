// vm sku https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-general

aks_vm_size = "Standard_F16s_v2"    
aks_nodecount = 4
aks_node_min_size = 3
aks_node_max_size = 10

// recommended for AKS price/perf D4-8ads_v5 or E4-8ads_v5
aks_pool2_vm_size = "Standard_D4d_v5"    
aks_pool2_nodecount = 1
aks_pool2_node_min_size = 1
aks_pool2_node_max_size = 5

// mysql sku https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-service-tiers-storage#service-tiers-size-and-server-types
mysql_contento_sku_name = "GP_Standard_D4ds_v4" 
mysql_contento_allocated_storage = 130
mysql_contento_iops_storage = 390

mysql_remp_sku_name = "GP_Standard_D4ds_v4" 
mysql_remp_allocated_storage = 240
mysql_remp_iops_storage = 720

mysql_onair_sku_name = "GP_Standard_D4ds_v4" 
mysql_onair_allocated_storage = 60
mysql_onair_iops_storage = 360

mysql_sku_name = "GP_Standard_D16ds_v4" 
mysql_allocated_storage = 60
mysql_iops_storage = 360

// redis sku https://azure.microsoft.com/en-in/pricing/details/cache/#pricing
redis_contento_capacity = 4
redis_contento_family = "C"
redis_contento_sku_name = "Standard"

redis_api_capacity = 3
redis_api_family = "C"
redis_api_sku_name = "Standard"

redis_sessions_capacity = 4
redis_sessions_family = "C"
redis_sessions_sku_name = "Standard"

redis_crm_capacity = 4
redis_crm_family = "C"
redis_crm_sku_name = "Standard"

elastic_sku_size = "Standard_E2d_v5"
elastic_data_storage_account_type = "PremiumV2_LRS"
elastic_data_disk_size = 40
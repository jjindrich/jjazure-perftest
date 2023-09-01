resource "azurerm_redis_cache" "contento" {
  name                = "${var.redis_name_prefix}-contento-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  capacity            = var.redis_contento_capacity
  family              = var.redis_contento_family
  sku_name            = var.redis_contento_sku_name
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  zones               = var.redis_avzones
  
  redis_configuration {
  }

  patch_schedule {
    day_of_week    = "Saturday"
    start_hour_utc = 0
  }
}

resource "azurerm_redis_cache" "cacheapi" {
  name                = "${var.redis_name_prefix}-api-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  capacity            = var.redis_api_capacity
  family              = var.redis_api_family
  sku_name            = var.redis_api_sku_name
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  zones               = var.redis_avzones

  redis_configuration {
  }
}

resource "azurerm_redis_cache" "cachesessions" {
  name                = "${var.redis_name_prefix}-sessions-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  capacity            = var.redis_sessions_capacity
  family              = var.redis_sessions_family
  sku_name            = var.redis_sessions_sku_name
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  zones               = var.redis_avzones

  redis_configuration {
  }
}

resource "azurerm_redis_cache" "cachecrm" {
  name                = "${var.redis_name_prefix}-crm-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  capacity            = var.redis_crm_capacity
  family              = var.redis_crm_family
  sku_name            = var.redis_crm_sku_name
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  zones               = var.redis_avzones
  
  redis_configuration {
  }
}

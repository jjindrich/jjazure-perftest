resource "azurerm_redis_cache" "contento" {
  name                = "${var.redis_name_prefix}-contento-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

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
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

resource "azurerm_redis_cache" "cachesessions" {
  name                = "${var.redis_name_prefix}-sessions-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

resource "azurerm_redis_cache" "cachecrm" {
  name                = "${var.redis_name_prefix}-crm-redis"
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg-svc.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

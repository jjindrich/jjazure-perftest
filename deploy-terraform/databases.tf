resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.dns_db_zone}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rsg.name
}

# Enables you to manage Private DNS zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_vnet" {
  name                  = azurerm_private_dns_zone.mysql.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  resource_group_name   = azurerm_resource_group.rsg.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Generate random value for the name
resource "random_password" "mysql_root_password" {
  length      = 8
  lower       = true
  min_lower   = 1
  numeric     = true
  min_numeric = 1
  special     = false
  upper       = true
  min_upper   = 1
}

resource "azurerm_mysql_flexible_server" "perftest" {
  name                   = "perftest"
  location               = azurerm_resource_group.rsg.location
  resource_group_name    = azurerm_resource_group.rsg.name
  administrator_login    = "azureadmin"
  administrator_password = random_password.mysql_root_password.result
  delegated_subnet_id    = azurerm_subnet.db-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "B_Standard_B1s"
  version                = "8.0.21"

  storage {
    iops    = 360
    size_gb = 20
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_vnet]

  lifecycle {
    ignore_changes = [ 
        zone
     ]
  }
}

resource "azurerm_mysql_flexible_database" "perftest" {
  name                = "perftest"
  resource_group_name = azurerm_resource_group.rsg.name
  server_name         = azurerm_mysql_flexible_server.perftest.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  lifecycle {
    ignore_changes = [ 
        charset,
        collation,
     ]
  }
}

resource "azurerm_mysql_flexible_server" "contento" {
  name                   = "contento"
  location               = azurerm_resource_group.rsg.location
  resource_group_name    = azurerm_resource_group.rsg.name
  administrator_login    = "azureadmin"
  administrator_password = var.mysql_contento_administrator_password != "" ? var.mysql_contento_administrator_password : random_password.mysql_root_password.result
  delegated_subnet_id    = azurerm_subnet.db-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "B_Standard_B1s"
  version                = "8.0.21"

  storage {
    iops    = 360
    size_gb = var.mysql_contento_allocated_storage
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_vnet]

  lifecycle {
    ignore_changes = [ 
        zone
     ]
  }
}

resource "azurerm_mysql_flexible_database" "contento" {
  name                = "contento"
  resource_group_name = azurerm_resource_group.rsg.name
  server_name         = azurerm_mysql_flexible_server.contento.name
  charset             = "utf8mb3"
  collation           = "utf8mb3_unicode_ci"

  lifecycle {
    ignore_changes = [ 
        charset,
        collation,
     ]
  }
}

resource "azurerm_mysql_flexible_server" "remp" {
  name                   = "remp"
  location               = azurerm_resource_group.rsg.location
  resource_group_name    = azurerm_resource_group.rsg.name
  administrator_login    = "azureadmin"
  administrator_password = var.mysql_remp_administrator_password != "" ? var.mysql_remp_administrator_password : random_password.mysql_root_password.result
  delegated_subnet_id    = azurerm_subnet.db-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "B_Standard_B1s"
  version                = "8.0.21"

  storage {
    iops    = 360
    size_gb = var.mysql_remp_allocated_storage
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_vnet]

  lifecycle {
    ignore_changes = [ 
        zone
     ]
  }
}

resource "azurerm_mysql_flexible_database" "remp" {
  name                = "remp"
  resource_group_name = azurerm_resource_group.rsg.name
  server_name         = azurerm_mysql_flexible_server.remp.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  lifecycle {
    ignore_changes = [ 
        charset,
        collation,
     ]
  }
}

resource "azurerm_mysql_flexible_server" "onair" {
  name                   = "onair"
  location               = azurerm_resource_group.rsg.location
  resource_group_name    = azurerm_resource_group.rsg.name
  administrator_login    = "azureadmin"
  administrator_password = var.mysql_onair_administrator_password != "" ? var.mysql_onair_administrator_password : random_password.mysql_root_password.result
  delegated_subnet_id    = azurerm_subnet.db-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "B_Standard_B1s"
  version                = "8.0.21"

  storage {
    iops    = 360
    size_gb = var.mysql_onair_allocated_storage
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_vnet]

  lifecycle {
    ignore_changes = [ 
        zone
     ]
  }
}

resource "azurerm_mysql_flexible_database" "onair" {
  name                = "onair"
  resource_group_name = azurerm_resource_group.rsg.name
  server_name         = azurerm_mysql_flexible_server.onair.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  lifecycle {
    ignore_changes = [ 
        charset,
        collation,
     ]
  }
}

resource "azurerm_mysql_flexible_server" "voyo" {
  name                   = "voyo"
  location               = azurerm_resource_group.rsg.location
  resource_group_name    = azurerm_resource_group.rsg.name
  administrator_login    = "azureadmin"
  administrator_password = var.mysql_voyo_administrator_password != "" ? var.mysql_voyo_administrator_password : random_password.mysql_root_password.result
  delegated_subnet_id    = azurerm_subnet.db-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "B_Standard_B1s"
  version                = "8.0.21"

  storage {
    iops    = 360
    size_gb = var.mysql_voyo_allocated_storage
  }

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_vnet]

  lifecycle {
    ignore_changes = [ 
        zone
     ]
  }
}

resource "azurerm_mysql_flexible_database" "voyo" {
  name                = "voyo"
  resource_group_name = azurerm_resource_group.rsg.name
  server_name         = azurerm_mysql_flexible_server.voyo.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  lifecycle {
    ignore_changes = [ 
        charset,
        collation,
     ]
  }
}

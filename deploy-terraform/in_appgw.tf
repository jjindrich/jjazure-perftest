# Generating a auto-renewing self signed certificate
resource "azurerm_key_vault_certificate" "self_signed_certificate" {
  name         = "ingress-certificate"
  key_vault_id = azurerm_key_vault.main.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["*.${var.ingress_hostname}", var.ingress_hostname]
      }

      subject            = "CN=${var.ingress_hostname}"
      validity_in_months = 12
    }
  }

  depends_on = [
    azurerm_role_assignment.kv_current_certificates
  ]
}

# App GW Instance
locals {
  backend_address_pool_name      = "${var.appgw_name}-beap"
  frontend_port_name             = "${var.appgw_name}-feport"
  frontend_ip_configuration_name = "${var.appgw_name}-feip"
  http_setting_name              = "${var.appgw_name}-be-htst"
  listener_name                  = "${var.appgw_name}-httplstn"
  request_routing_rule_name      = "${var.appgw_name}-rqrt"
  redirect_configuration_name    = "${var.appgw_name}-rdrcfg"
}

resource "azurerm_public_ip" "appgw" {
  name                = "${var.appgw_name}-pip"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "gateway" {
  name                = var.appgw_name
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  identity {
    type = "UserAssigned" // needed for key vault access
    identity_ids = [
      azurerm_user_assigned_identity.appgw.id
    ]
  }

  dynamic "autoscale_configuration" {
    for_each = var.appgw_scale_max > 0 ? [1] : []

    content {
      min_capacity = var.appgw_scale_min
      max_capacity = var.appgw_scale_max
    }
  }

  ssl_certificate {
    name                = "ingress"
    key_vault_secret_id = azurerm_key_vault_certificate.self_signed_certificate.versionless_secret_id
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.appgw-subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  probe {
    name                = "probe-perftest"
    interval            = 60
    protocol            = "Http"
    path                = "/test"
    timeout             = 30
    unhealthy_threshold = 5
    host                = "perftest.local"
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "probe-perftest"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "ingress"
  }

  request_routing_rule {
    name                       = "route-443"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 100
  }
}

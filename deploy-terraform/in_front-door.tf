locals {
  front_door_profile_name      = "perftest"
  front_door_endpoint_name     = "haproxyendpoint"
  front_door_origin_group_name = "haproxygrp"
  front_door_origin_name       = "haproxyorigin"
  front_door_route_name        = "haproxyroute"
}

resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                = var.front_door_name
  resource_group_name = azurerm_resource_group.rsg.name
  sku_name            = var.front_door_sku_name
}

resource "azurerm_cdn_frontdoor_origin_group" "haproxy" {
  name                     = local.front_door_origin_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id

  session_affinity_enabled = false

  health_probe {
    interval_in_seconds = 30
    path                = "/test"
    protocol            = "Http"
    request_type        = "GET"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "haproxy_lb" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.haproxy.id
  enabled                       = true

  certificate_name_check_enabled = false

  host_name          = azurerm_public_ip.haproxy_lb1.ip_address
  http_port          = 80
  https_port         = 443
  origin_host_header = azurerm_public_ip.haproxy_lb1.ip_address
  priority           = 1
  weight             = 1000
}

resource "azurerm_cdn_frontdoor_endpoint" "haproxy" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
}

resource "azurerm_cdn_frontdoor_route" "haproxy" {
  name                          = "haproxy"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.haproxy.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.haproxy.id
  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.haproxy_lb.id,
  ]

  enabled = true

  forwarding_protocol    = "HttpOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  //cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.contoso.id]
  link_to_default_domain = true

  cache {
    compression_enabled       = true
    content_types_to_compress = ["text/html", "text/javascript", "text/xml"]
  }
}

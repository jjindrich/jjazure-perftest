/*
data "azurerm_dns_zone" "app" {
  name                = "conto.in"
  resource_group_name = "core-domains"
}

resource "azurerm_cdn_frontdoor_custom_domain" "app" {
  name                     = "fd-customDomain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  dns_zone_id              = data.azurerm_dns_zone.app.id
  host_name                = "perftest.fd.conto.in"

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "app" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.app.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.haproxy.id]
}

resource "azurerm_dns_cname_record" "fd_domain" {
  depends_on = [azurerm_cdn_frontdoor_route.haproxy] //, azurerm_cdn_frontdoor_security_policy.example]

  name                = "contoso"
  zone_name           = data.azurerm_dns_zone.app.id
  resource_group_name = azurerm_resource_group.rsg.name
  ttl                 = 3600
  record              = azurerm_cdn_frontdoor_endpoint.haproxy.host_name
}

resource "azurerm_dns_txt_record" "fd_domain" {
  name                = join(".", ["_dnsauth", "perftest", "fd"])
  zone_name           = data.azurerm_dns_zone.app.id
  resource_group_name = azurerm_resource_group.rsg.name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.app.validation_token
  }
}
*/
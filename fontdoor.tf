

hcl
resource "azurerm_cdn_frontdoor_profile" "fdp" {
  name                = "${var.prefix}-fdp-${random_string.sfx.result}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = local.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "fde" {
  name                     = "${var.prefix}-fd-${random_string.sfx.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
  tags                     = local.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "forge" {
  name                     = "${var.prefix}-og-forge-${random_string.sfx.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
  health_probe {
    interval_in_seconds = 30
    protocol            = "Https"
    path                = "/"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "wallet" {
  name                     = "${var.prefix}-og-wallet-${random_string.sfx.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
  health_probe {
    interval_in_seconds = 30
    protocol            = "Https"
    path                = "/"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "ballance" {
  name                     = "${var.prefix}-og-ballance-${random_string.sfx.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
  health_probe {
    interval_in_seconds = 30
    protocol            = "Https"
    path                = "/"
  }
}

resource "azurerm_cdn_frontdoor_origin" "forge" {
  name                          = "${var.prefix}-o-forge-${random_string.sfx.result}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.forge.id
  enabled                       = true
  host_name          = azurerm_linux_web_app.forge.default_hostname
  origin_host_header = azurerm_linux_web_app.forge.default_hostname
  http_port          = 80
  https_port         = 443
  priority           = 1
  weight             = 1000
}

resource "azurerm_cdn_frontdoor_origin" "wallet" {
  name                          = "${var.prefix}-o-wallet-${random_string.sfx.result}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.wallet.id
  enabled                       = true
  host_name          = azurerm_linux_web_app.wallet.default_hostname
  origin_host_header = azurerm_linux_web_app.wallet.default_hostname
  http_port          = 80
  https_port         = 443
  priority           = 1
  weight             = 1000
}

resource "azurerm_cdn_frontdoor_origin" "ballance" {
  name                          = "${var.prefix}-o-ballance-${random_string.sfx.result}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.ballance.id
  enabled                       = true
  host_name          = azurerm_linux_web_app.ballance.default_hostname
  origin_host_header = azurerm_linux_web_app.ballance.default_hostname
  http_port          = 80
  https_port         = 443
  priority           = 1
  weight             = 1000
}

resource "azurerm_cdn_frontdoor_route" "forge" {
  name                          = "${var.prefix}-r-forge-${random_string.sfx.result}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fde.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.forge.id
  supported_protocols           = ["Https"]
  patterns_to_match             = ["/forge/*"]
  https_redirect_enabled        = true
  forwarding_protocol           = "HttpsOnly"
}

resource "azurerm_cdn_frontdoor_route" "wallet" {
  name                          = "${var.prefix}-r-wallet-${random_string.sfx.result}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fde.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.wallet.id
  supported_protocols           = ["Https"]
  patterns_to_match             = ["/wallet/*"]
  https_redirect_enabled        = true
  forwarding_protocol           = "HttpsOnly"
}

resource "azurerm_cdn_frontdoor_route" "ballance" {
  name                          = "${var.prefix}-r-ballance-${random_string.sfx.result}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fde.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.ballance.id
  supported_protocols           = ["Https"]
  patterns_to_match             = ["/ballance/*"]
  https_redirect_enabled        = true
  forwarding_protocol           = "HttpsOnly"
}

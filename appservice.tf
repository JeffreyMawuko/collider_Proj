hcl
resource "azurerm_service_plan" "asp" {
  name                = "${var.prefix}-asp-${random_string.sfx.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1" # Standard
  tags                = local.tags
}

# Additional locals for app settings
locals {
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "DB_CONNECTION_STRING"     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_connstr.id})"
  }
}

# Web App: forge
resource "azurerm_linux_web_app" "forge" {
  name                = "${var.prefix}-${random_string.sfx.result}-forge"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  identity { type = "SystemAssigned" }

  site_config {
    minimum_tls_version           = "1.2"
    http2_enabled                 = true
    ftps_state                    = "Disabled"
    vnet_route_all_enabled        = true
    ip_restriction_default_action = "Deny"

    ip_restriction {
      name        = "Allow-AzureFrontDoor"
      priority    = 100
      action      = "Allow"
      service_tag = "AzureFrontDoor.Backend"
    }
  }

  app_settings = local.app_settings
  tags         = merge(local.tags, { app = "forge" })
}

# Web App: wallet
resource "azurerm_linux_web_app" "wallet" {
  name                = "${var.prefix}-${random_string.sfx.result}-wallet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  identity { type = "SystemAssigned" }

  site_config {
    minimum_tls_version           = "1.2"
    http2_enabled                 = true
    ftps_state                    = "Disabled"
    vnet_route_all_enabled        = true
    ip_restriction_default_action = "Deny"

    ip_restriction {
      name        = "Allow-AzureFrontDoor"
      priority    = 100
      action      = "Allow"
      service_tag = "AzureFrontDoor.Backend"
    }
  }

  app_settings = local.app_settings
  tags         = merge(local.tags, { app = "wallet" })
}

# Web App: ballance
resource "azurerm_linux_web_app" "ballance" {
  name                = "${var.prefix}-${random_string.sfx.result}-ballance"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  identity { type = "SystemAssigned" }

  site_config {
    minimum_tls_version           = "1.2"
    http2_enabled                 = true
    ftps_state                    = "Disabled"
    vnet_route_all_enabled        = true
    ip_restriction_default_action = "Deny"

    ip_restriction {
      name        = "Allow-AzureFrontDoor"
      priority    = 100
      action      = "Allow"
      service_tag = "AzureFrontDoor.Backend"
    }
  }

  app_settings = local.app_settings
  tags         = merge(local.tags, { app = "ballance" })
}

# Grant each app access to Key Vault secrets
resource "azurerm_key_vault_access_policy" "app_forge" {
  key_vault_id        = azurerm_key_vault.kv.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_web_app.forge.identity[0].principal_id
  secret_permissions  = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "app_wallet" {
  key_vault_id        = azurerm_key_vault.kv.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_web_app.wallet.identity[0].principal_id
  secret_permissions  = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "app_ballance" {
  key_vault_id        = azurerm_key_vault.kv.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_web_app.ballance.identity[0].principal_id
  secret_permissions  = ["Get", "List"]
}

# VNet Integration for private access to SQL/KV
resource "azurerm_app_service_virtual_network_swift_connection" "forge" {
  app_service_id = azurerm_linux_web_app.forge.id
  subnet_id      = azurerm_subnet.appsvc.id
}

resource "azurerm_app_service_virtual_network_swift_connection" "wallet" {
  app_service_id = azurerm_linux_web_app.wallet.id
  subnet_id      = azurerm_subnet.appsvc.id
}

resource "azurerm_app_service_virtual_network_swift_connection" "ballance" {
  app_service_id = azurerm_linux_web_app.ballance.id
  subnet_id      = azurerm_subnet.appsvc.id
}

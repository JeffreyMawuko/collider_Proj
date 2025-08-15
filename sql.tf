hcl
resource "random_password" "sql_admin" {
  length           = 32
  special          = true
  override_special = "!@#%&*()-_=+[]{}"
}

resource "azurerm_mssql_server" "sql" {
  name                         = "${var.prefix}-sql-${random_string.sfx.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_admin.result
  minimum_tls_version          = "1.2"
  public_network_access_enabled = false
  tags                         = local.tags
}

resource "azurerm_mssql_database" "db" {
  name           = "${var.prefix}-db-${random_string.sfx.result}"
  server_id      = azurerm_mssql_server.sql.id
  sku_name       = "S0"
  zone_redundant = false
  tags           = local.tags
}

# Store credentials & connection string in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_user" {
  name         = "sql-admin-username"
  value        = var.sql_admin_username
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "sql_admin_pass" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_connstr" {
  name         = "db-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${random_password.sql_admin.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv.id
}

# Private DNS + Private Endpoints for SQL & KV
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_vnet" {
  name                  = "${var.prefix}-sqlzone-link-${random_string.sfx.result}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "sql" {
  name                = "${var.prefix}-pe-sql-${random_string.sfx.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.backend.id
  tags                = local.tags

  private_service_connection {
    name                           = "${var.prefix}-sql-privlink"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone_group" "sql" {
  name                 = "${var.prefix}-sql-dnsgrp"
  private_endpoint_id  = azurerm_private_endpoint.sql.id
  private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
}

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_vnet" {
  name                  = "${var.prefix}-kvzone-link-${random_string.sfx.result}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "kv" {
  name                = "${var.prefix}-pe-kv-${random_string.sfx.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.backend.id
  tags                = local.tags

  private_service_connection {
    name                           = "${var.prefix}-kv-privlink"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone_group" "kv" {
  name                 = "${var.prefix}-kv-dnsgrp"
  private_endpoint_id  = azurerm_private_endpoint.kv.id
  private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
}

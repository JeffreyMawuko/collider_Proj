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

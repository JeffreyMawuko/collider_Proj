hcl
output "resource_group" { value = azurerm_resource_group.rg.name }

output "vnet_name" { value = azurerm_virtual_network.vnet.name }

output "subnets" {
  value = {
    backend  = azurerm_subnet.backend.name
    frontend = azurerm_subnet.frontend.name
    appsvc   = azurerm_subnet.appsvc.name
  }
}

output "key_vault_name" { value = azurerm_key_vault.kv.name }

output "sql_server_fqdn" { value = azurerm_mssql_server.sql.fully_qualified_domain_name }

output "sql_database_name" { value = azurerm_mssql_database.db.name }

output "webapps" {
  value = {
    forge    = azurerm_linux_web_app.forge.default_hostname
    wallet   = azurerm_linux_web_app.wallet.default_hostname
    ballance = azurerm_linux_web_app.ballance.default_hostname
  }
}

output "frontdoor_endpoint" { value = azurerm_cdn_frontdoor_endpoint.fde.host_name }

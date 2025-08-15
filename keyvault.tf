hcl
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-${var.prefix}-${random_string.sfx.result}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = local.tags
}

# Access policy for Terraform executor (who is running 'apply')
resource "azurerm_key_vault_access_policy" "tfexec" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
}

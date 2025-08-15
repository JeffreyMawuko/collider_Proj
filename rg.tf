hcl
resource "azurerm_resource_group" "rg" {
  name     = "Production"
  location = var.location
  tags     = local.tags
}

resource "random_string" "sfx" {
  length  = 5
  upper   = false
  numeric = true
  special = false
}

hcl
# Optional: Assign PCI DSS policy initiative at RG scope (provide var value to enable)
resource "azurerm_policy_assignment" "pci_dss" {
  count                = var.pci_policy_set_definition_id == "" ? 0 : 1
  name                 = "${var.prefix}-pci-dss-${random_string.sfx.result}"
  display_name         = "PCI DSS 3.2.1 — RG Assignment"
  location             = azurerm_resource_group.rg.location
  scope                = azurerm_resource_group.rg.id
  policy_definition_id = var.pci_policy_set_definition_id
  enforcement_mode     = "Default"
}

# Logic App for daily PCI check via Policy Insights (Managed Identity)
resource "azurerm_logic_app_workflow" "pci_check" {
  name                = "${var.prefix}-pci-check-${random_string.sfx.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  identity { type = "SystemAssigned" }
  tags = local.tags

  definition = jsonencode({
    "$schema"       = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion"= "1.0.0.0",
    "parameters"    = {},
    "triggers"      = {
      "every_day" = {
        "type" = "Recurrence",
        "recurrence" = { "frequency" = "Day", "interval" = 1 }
      }
    },
    "actions"       = {
      "queryPolicyStates" = {
        "type"   = "Http",
        "inputs" = {
          "method" = "POST",
          "uri"    = concat(
            "https://management.azure.com/",
            "subscriptions/",
            subscription().subscriptionId,
            "/providers/Microsoft.PolicyInsights/policyStates/latest/queryResults?api-version=2022-04-01"
          ),
          "authentication" = { "type" = "ManagedServiceIdentity" },
          "headers"        = { "Content-Type" = "application/json" },
          "body"           = {
            "query" = "SELECT COUNT() as NonCompliant FROM policyresources WHERE ComplianceState = 'NonCompliant' AND ResourceGroup = '${azurerm_resource_group.rg.name}'"
          }
        }
      }
    },
    "outputs" = {}
  })
}

# tfsec configuration file written to repo root
resource "local_file" "tfsec_config" {
  filename = "./.tfsec.yml"
  content  = <<-YAML
    severity: MEDIUM
    ignore-hcl-errors: false
    exclude: []
    soft-fail: false
    additional-checks: []
  YAML
}

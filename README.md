# Collider_Project

This is a project for balance and forge Africa-appservices

Architecture Design

# Project Description:

My project is a production-ready Terraform stack for ColliderAfrica. This sets up an RG Production in “East EU” (defaulted to northeurope, but you can change var.location if required).

The VNet **ProdvNet** with backend and frontend subnets plus a dedicated appsvc subnet (this is required for secure Web App VNet Integration). App Service Plan used is (S1 Standard) and three hardened Linux Web Apps: forge, wallet, balance. HTTPS-only, TLS ≥1.2, FTP disabled for security purposes for now, *IP-restricted to Azure Front Door only*. Managed identity on each app; Key Vault references for the **DB connection** string (no plaintext secrets). Azure SQL (S0) with **public access **disabled, Private Endpoint, and Private DNS. Azure Key Vault (soft delete & purge protection) with Private Endpoint + access policies for each app’s identity. Azure Front Door (Standard/Premium) with routes for /forge/*, /wallet/*, /ballance/*, providing global LB + HA.

**Compliance & Security**

A Logic App (managed identity) that queries Azure Policy (PCI DSS) daily. A repo .tfsec.yml so you can run tfsec. locally. Optional **PCI DSS** policy assignment at the RG scope (supply the built-in initiative ID via pci_policy_set_definition_id).

## SQL Database

The SQL admin password is generated and stored in Key Vault. The apps fetch the full connection string via KV reference; nothing is output to the console.


**Next steps**
1. Commit these files to a new repo root.
2. Optionally add a `terraform.tfvars` with:
```hcl
prefix = "forge"
location = "northeurope"
# pci_policy_set_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/<PCI_DSS_ID>"
```
3. Run `terraform init && terraform plan && terraform apply`. If using GitHub Actions, add a simple workflow to run on push (I can add that too if you want).


Contact: info@VtechUB4dev.com

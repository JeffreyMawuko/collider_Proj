hcl
variable "prefix" {
  description = "Short prefix for all resources (e.g., 'forge')."
  type        = string
  default     = "forge"
}

variable "location" {
  description = "Azure region. Using 'northeurope' as East EU default."
  type        = string
  default     = "northeurope"
}

variable "address_space" {
  description = "VNet address space."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "backend_subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "frontend_subnet_cidr" {
  type    = string
  default = "10.10.2.0/24"
}

variable "appsvc_subnet_cidr" {
  description = "Dedicated subnet for App Service VNet Integration."
  type        = string
  default     = "10.10.3.0/27"
}

variable "sql_admin_username" {
  description = "SQL admin username (password is generated)."
  type        = string
  default     = "sqladmin"
}

variable "pci_policy_set_definition_id" {
  description = "Policy Set (Initiative) ID for PCI DSS assignment. Leave empty to skip."
  type        = string
  default     = ""
}

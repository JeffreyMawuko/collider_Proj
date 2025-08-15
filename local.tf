hcl
locals {
  tags = {
    environment = "prod"
    owner       = "platform"
    system      = var.prefix
    costcenter  = "prod-apps"
  }
}

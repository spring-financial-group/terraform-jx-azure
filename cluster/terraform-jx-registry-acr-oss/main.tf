// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// ----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.2"
  required_providers {
    azurerm = {
      version = ">=4.23.0"
    }
  }
}

data "azurerm_container_registry" "oss_acr_existing" {
    count = var.oss_acr_pull_enabled ? 1 : 0
    name                = var.oss_registry_name
    resource_group_name = var.resource_group_name
}

resource "azurerm_container_registry" "oss_acr" {
  count                  = var.oss_acr_enabled ? 1 : 0
  name                   = var.oss_registry_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku                    = var.sku
  anonymous_pull_enabled = local.anonymous_pull_enabled
  admin_enabled          = local.admin_enabled
}

resource "azurerm_role_assignment" "oss_push" {
  count                = var.oss_acr_enabled ? 1 : 0
  scope                = azurerm_container_registry.oss_acr[0].id
  role_definition_name = local.AcrPush_definition_name
  principal_id         = var.principal_id
}

resource "azurerm_role_assignment" "acrpull" {
  count                = var.oss_acr_pull_enabled ? 1 : 0
  scope                = data.azurerm_container_registry.oss_acr_existing[0].id
  role_definition_name = "AcrPull"
  principal_id         = var.principal_id
}

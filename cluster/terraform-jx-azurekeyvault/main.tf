// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// ----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.4.6"
  required_providers {
    azurerm = {
      version = ">=4.23.0"
    }
  }
}

// ----------------------------------------------------------------------------
// Retrieve active subscription resources are being created in
// ----------------------------------------------------------------------------
data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

// ----------------------------------------------------------------------------
// Setup Azure Resource Groups
// ----------------------------------------------------------------------------

resource "azurerm_resource_group" "key_vault" {
  count    = var.enabled ? 1 : 0
  name     = local.resource_group_name
  location = var.location
}

// ----------------------------------------------------------------------------
// Setup Azure Resources
// ----------------------------------------------------------------------------

# tfsec:ignore:azure-keyvault-specify-network-acl
resource "azurerm_key_vault" "jx" {
  count                      = var.enabled ? 1 : 0
  location                   = var.location
  name                       = local.key_vault_name
  resource_group_name        = azurerm_resource_group.key_vault.0.name
  sku_name                   = var.key_vault_sku
  tenant_id                  = local.tenant_id
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
}

resource "azurerm_key_vault_access_policy" "jx" {
  count        = var.enabled ? 1 : 0
  key_vault_id = azurerm_key_vault.jx.0.id
  object_id    = var.principal_id
  tenant_id    = local.tenant_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
  ]
}

resource "azurerm_key_vault_access_policy" "terraform" {
  count        = var.enabled ? 1 : 0
  key_vault_id = azurerm_key_vault.jx.0.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = local.tenant_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
  ]
}

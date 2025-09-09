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

resource "azurerm_resource_group" "acr" {
  count = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0

  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  count               = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                = local.container_registry_name
  resource_group_name = azurerm_resource_group.acr[0].name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
}

data "azurerm_container_registry" "acr_existing" {
  count = var.acr_enabled && var.use_existing_acr_name != null ? 1 : 0

  name                = var.use_existing_acr_name
  resource_group_name = var.use_existing_acr_resource_group_name
}

resource "azurerm_container_registry_scope_map" "acr_scope_map" {
  name                    = local.container_registry_scope_map_name
  container_registry_name = local.container_registry_name
  resource_group_name     = azurerm_resource_group.acr[0].name
  actions = [
    "metadata/read",
    "metadata/write",
    "content/read",
    "content/write",
    "content/delete"
  ]
}

resource "azurerm_container_registry_token" "acr_registry_token" {
  name                    = local.container_registry_token_name
  container_registry_name = local.container_registry_name
  resource_group_name     = azurerm_resource_group.acr[0].name
  scope_map_id            = azurerm_container_registry_scope_map.acr_scope_map.id
}

resource "azurerm_container_registry_token_password" "acr_registry_token_password" {
  container_registry_token_id = azurerm_container_registry_token.acr_registry_token.id

  password1 {
  }
}

resource "azurerm_role_assignment" "acrpull" {
  count                = var.acr_enabled && var.external_registry_url == "" ? 1 : 0
  scope                = var.use_existing_acr_name == null ? azurerm_container_registry.acr[0].id : data.azurerm_container_registry.acr_existing[0].id
  role_definition_name = "AcrPull"
  principal_id         = var.principal_id
}

resource "azurerm_role_assignment" "acrpush" {
  count                = var.acr_enabled && var.external_registry_url == "" ? 1 : 0
  scope                = var.use_existing_acr_name == null ? azurerm_container_registry.acr[0].id : data.azurerm_container_registry.acr_existing[0].id
  role_definition_name = "AcrPush"
  principal_id         = var.principal_id
}

resource "azurerm_container_registry_cache_rule" "cache_rule" {
  count                 = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                  = "docker-io"
  container_registry_id = azurerm_container_registry.acr[0].id
  target_repo           = "docker-io/*"
  source_repo           = "docker.io/*"
  credential_set_id     = "${azurerm_container_registry.acr[0].id}/credentialSets/dockerhub-cred"
}

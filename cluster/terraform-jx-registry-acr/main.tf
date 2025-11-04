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

# Scope Map to allow pulling of containers and charts from MQube's ACR

resource "azurerm_container_registry_scope_map" "acr_scope_map" {
  for_each = var.saas_map

  name                    = "scope-map-${each.key}"
  container_registry_name = local.container_registry_name
  resource_group_name     = local.resource_group_name
  actions = [
    "repositories/spring-financial-group/charts/*/content/read",
    "repositories/spring-financial-group/charts/*/metadata/read"
  ]
}

resource "azurerm_container_registry_token" "acr_registry_token" {
  for_each = var.saas_map
  name                    = "token-${each.key}"
  container_registry_name = local.container_registry_name
  resource_group_name     = local.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.acr_scope_map[each.key].id
}

resource "azurerm_container_registry_token_password" "acr_registry_token_password" {
  for_each = var.saas_map
  container_registry_token_id = azurerm_container_registry_token.acr_registry_token[each.key].id

  password1 {
  }
}

# Pullthrough cache rules for public registries

resource "azurerm_container_registry_cache_rule" "cache_rule" {
  count                 = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                  = "docker-io"
  container_registry_id = azurerm_container_registry.acr[0].id
  target_repo           = "docker-io/*"
  source_repo           = "docker.io/*"
  credential_set_id     = "${azurerm_container_registry.acr[0].id}/credentialSets/dockerhub-cred"
}

resource "azurerm_container_registry_cache_rule" "cache_rule_mcr" {
  count                 = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                  = "mcr-microsoft-com"
  container_registry_id = azurerm_container_registry.acr[0].id
  target_repo           = "mcr-microsoft-com/*"
  source_repo           = "mcr.microsoft.com/*"
}

resource "azurerm_container_registry_cache_rule" "cache_rule_quay" {
  count                 = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                  = "quay-io"
  container_registry_id = azurerm_container_registry.acr[0].id
  target_repo           = "quay-io/*"
  source_repo           = "quay.io/*"
}

resource "azurerm_container_registry_cache_rule" "cache_rule_gcr" {
  count                 = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                  = "gcr-io"
  container_registry_id = azurerm_container_registry.acr[0].id
  target_repo           = "gcr-io/*"
  source_repo           = "gcr.io/*"
}

resource "azurerm_container_registry_cache_rule" "cache_rule_ghcr" {
  count                 = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                  = "ghcr-io"
  container_registry_id = azurerm_container_registry.acr[0].id
  target_repo           = "ghcr-io/*"
  source_repo           = "ghcr.io/*"
}

resource "azurerm_container_registry_cache_rule" "cache_rule_k8s" {
  count                 = var.acr_enabled && var.external_registry_url == "" && var.use_existing_acr_name == null ? 1 : 0
  name                  = "registry-k8s-io"
  container_registry_id = azurerm_container_registry.acr[0].id
  target_repo           = "registry-k8s-io/*"
  source_repo           = "registry.k8s.io/*"
}

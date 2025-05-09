resource "random_pet" "name" {
}

data "azurerm_subscription" "current" {
}

locals {
  cluster_name = var.cluster_name != "" ? join("", regexall("[A-Za-z0-9\\-]", var.cluster_name)) : join("", regexall("[A-Za-z0-9\\-]", random_pet.name.id))

  registry_secrets = {
    jx-dev-registry-username : module.registry.admin_username,
    jx-dev-registry-password : module.registry.admin_password,
  }

  merged_secrets = merge(local.registry_secrets)

  job_secret_env_vars = var.key_vault_enabled ? {
    AZURE_TENANT_ID       = module.secrets.tenant_id
    AZURE_SUBSCRIPTION_ID = module.secrets.subscription_id
    AZURE_CLIENT_ID       = module.secrets.client_id
  } : {}
}

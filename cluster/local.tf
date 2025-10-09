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

  job_secret_env_vars_vault = var.key_vault_enabled ? {
    AZURE_TENANT_ID       = module.secrets.tenant_id
    AZURE_SUBSCRIPTION_ID = module.secrets.subscription_id
    AZURE_CLIENT_ID       = module.secrets.client_id
  } : {}

  job_secret_env_vars_acr = var.enable_acr_chart_registry ? {
    JX_REPOSITORY_USERNAME = local.registry_secrets["jx-dev-registry-username"]
    JX_REPOSITORY_PASSWORD = local.registry_secrets["jx-dev-registry-password"]
  } : {}

  job_secret_env_vars = merge({}, local.job_secret_env_vars_vault, local.job_secret_env_vars_acr)
}

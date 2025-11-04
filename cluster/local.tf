resource "random_pet" "name" {
}

data "azurerm_subscription" "current" {
}

# Conditionally import the remote registry state for SaaS clusters
data "terraform_remote_state" "registry" {
  count = var.is_saas_org ? 1 : 0

  backend = "remote"

  config = {
    organization = "mqube"
    workspaces = {
      name = "terraform-jx-azure"
    }
  }
}

locals {
  cluster_name = var.cluster_name != "" ? join("", regexall("[A-Za-z0-9\\-]", var.cluster_name)) : join("", regexall("[A-Za-z0-9\\-]", random_pet.name.id))

  # Get the token for *this* tenant
  mqube_registry_token_name = var.is_saas_org ? lookup(
    try(data.terraform_remote_state.registry[0].outputs.acr_registry_token_names, {}),
    var.saas_org_name,
    null
  ) : null

  mqube_registry_token_password = var.is_saas_org ? lookup(
    try(data.terraform_remote_state.registry[0].outputs.acr_registry_token_passwords, {}),
    var.saas_org_name,
    null
  ) : null

  registry_secrets = {
    jx-dev-registry-username : module.registry.admin_username,
    jx-dev-registry-password : module.registry.admin_password,
  }

  mqube_registry_secrets = var.is_saas_org ? {
    mqube-tech-registry-username = local.mqube_registry_token_name,
    mqube-tech-registry-password = local.mqube_registry_token_password,
  } : {}

  merged_secrets = merge({}, local.registry_secrets, local.mqube_registry_secrets)

  job_secret_env_vars_vault = var.key_vault_enabled ? {
    AZURE_TENANT_ID       = module.secrets.tenant_id
    AZURE_SUBSCRIPTION_ID = module.secrets.subscription_id
    AZURE_CLIENT_ID       = module.secrets.client_id
  } : {}

  job_secret_env_vars_acr = var.enable_acr_chart_registry ? {
    # used by `jx gitops helm` to interact with ACR
    JX_REPOSITORY_USERNAME = local.registry_secrets["jx-dev-registry-username"]
    JX_REPOSITORY_PASSWORD = local.registry_secrets["jx-dev-registry-password"]
    # used by `helmfile` to interact with the "dev" chart repository
    DEV_USERNAME = local.registry_secrets["jx-dev-registry-username"]
    DEV_PASSWORD = local.registry_secrets["jx-dev-registry-password"]
  } : {}

  # Conditionally include MQube tech vars depending on cluster type
  job_secret_env_vars_mqube_tech = var.is_saas_org ? (
    local.mqube_registry_token_name != null && local.mqube_registry_token_password != null ? {
    MQUBE_TECH_USERNAME = local.mqube_registry_secrets["mqube-tech-registry-username"]
    MQUBE_TECH_PASSWORD = local.mqube_registry_secrets["mqube-tech-registry-password"]
  } : {
    MQUBE_TECH_USERNAME = "foo"
    MQUBE_TECH_PASSWORD = "bar"
  }
  ) : {}

  job_secret_env_vars = merge({}, local.job_secret_env_vars_vault, local.job_secret_env_vars_acr, local.job_secret_env_vars_mqube_tech)
}

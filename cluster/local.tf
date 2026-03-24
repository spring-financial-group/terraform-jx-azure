resource "random_pet" "name" {
}

data "azurerm_subscription" "current" {
}

locals {
  cluster_name = var.cluster_name != "" ? join("", regexall("[A-Za-z0-9\\-]", var.cluster_name)) : join("", regexall("[A-Za-z0-9\\-]", random_pet.name.id))

  # The default and infra pools can surge by max_node_surge / max_infra_node_surge during upgrades.
  # Other pools have no explicit upgrade_settings so AKS defaults to a surge of 1 node each.
  # We account for both to avoid under-allocating ports.
  total_max_nodes = var.enable_loadbalancer_outbound_ports_allocation ? (
    ceil(var.max_node_count * (1 + var.max_node_surge)) +
    (var.ml_node_size != "" ? coalesce(var.max_ml_node_count, 0) + 1 : 0) +
    (var.llm_node_size != "" ? coalesce(var.max_llm_node_count, 0) + 1 : 0) +
    (var.build_node_size != "" ? coalesce(var.max_build_node_count, 0) + 1 : 0) +
    (var.infra_node_size != "" ? ceil(coalesce(var.max_infra_node_count, 0) * (1 + var.max_infra_node_surge)) : 0) +
    (var.mlbuild_node_size != "" ? coalesce(var.max_mlbuild_node_count, 0) + 1 : 0)
  ) : 0

  # Allocate node ports based on the maximum number of nodes the cluster can scale to, with 64,000 ports allowed per-outbound IP.
  # Result is the largest multiple of 8 that does not exceed (64512 * outbound_ip_count / max_nodes).
  cluster_loadbalancer_outbound_ports_allocated = var.enable_loadbalancer_outbound_ports_allocation ? floor(
    64512 * var.cluster_managed_outbound_ip_count / local.total_max_nodes / 8
  ) * 8 : 0

  registry_secrets = {
    jx-dev-registry-username : module.registry.admin_username,
    jx-dev-registry-password : module.registry.admin_password,
  }

  mqube_registry_secrets = var.enable_mqube_tech_acr_readonly ? {
    mqube-tech-reg-username : var.pull_only_registry_token_name,
    mqube-tech-reg-password : var.pull_only_registry_token_password,
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

  job_secret_env_vars_mqube_tech = var.enable_mqube_tech_acr_readonly ? {
    MQUBE_TECH_USERNAME = local.mqube_registry_secrets["mqube-tech-reg-username"]
    MQUBE_TECH_PASSWORD = local.mqube_registry_secrets["mqube-tech-reg-password"]
  } : {}

  job_secret_env_vars = merge({}, local.job_secret_env_vars_vault, local.job_secret_env_vars_acr, local.job_secret_env_vars_mqube_tech)
}

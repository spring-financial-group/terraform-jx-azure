locals {
  jx_requirements_interpolated_content = templatefile("${path.module}/jx-requirements.yml.tpl", {

    registry_name            = module.registry.registry_name
    domain                   = module.dns.domain
    apex_domain              = var.apex_domain
    subdomain                = var.subdomain
    domain_enabled           = var.apex_domain != "" ? true : false
    dns_resource_group       = module.dns.resource_group_name
    dns_tenant_id            = module.dns.tenant_id
    dns_subscription_id      = module.dns.subscription_id
    key_vault_enabled        = var.key_vault_enabled
    key_vault_name           = module.secrets.key_vault_name
    log_container_name       = module.storage.log_container_name
    storage_account_name     = module.storage.storage_account_name
    vault_installed          = module.jx-boot.vault_instance_release_id != "" ? true : false
    kubelet_client_id        = module.cluster.kubelet_client_id
  })

  jx_requirements_split_content   = split("\n", local.jx_requirements_interpolated_content)
  jx_requirements_compact_content = compact(local.jx_requirements_split_content)
  jx_requirements_content         = join("\n", local.jx_requirements_compact_content)

  enable_cluster_user_rbac = var.enable_cluster_user_rbac
}

data "azuread_group" "jx_dev_team" {
  count        = local.enable_cluster_user_rbac ? 1 : 0
  display_name = "JX Dev Team"
}

data "azuread_group" "jx_readonly_team" {
  count        = local.enable_cluster_user_rbac ? 1 : 0
  display_name = "JX Readonly Team"
}

resource "kubernetes_config_map" "jenkins_x_requirements" {
  metadata {
    name      = "terraform-jx-requirements"
    namespace = "default"
  }
  data = {
    "jx-requirements.yml" = local.jx_requirements_content
  }

  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
  depends_on = [
    module.cluster
  ]
}



resource "azurerm_role_assignment" "jx_dev_cluster_user_role" {
  count                = local.enable_cluster_user_rbac ? 1 : 0
  scope                = module.cluster.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azuread_group.jx_dev_team[0].id
  depends_on = [
    module.cluster
  ]
}

resource "azurerm_role_assignment" "jx_readonly_cluster_user_role" {
  count                = local.enable_cluster_user_rbac ? 1 : 0
  scope                = module.cluster.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azuread_group.jx_readonly_team[0].id
}

resource "kubernetes_manifest" "jx_dev_cluster_role" {
  count    = local.enable_cluster_user_rbac ? 1 : 0
  manifest = yamldecode(file("${path.module}/terraform-jx-cluster-aks/rbac/dev/jx-dev-cr.yaml"))
  depends_on = [
    module.cluster
  ]
}

resource "kubernetes_manifest" "jx_dev_cluster_role_binding" {
  count = local.enable_cluster_user_rbac ? 1 : 0
  manifest = yamldecode(templatefile(
    "${path.module}/terraform-jx-cluster-aks/rbac/dev/jx-dev-crb.yaml",
    {
      group_object_id = data.azuread_group.jx_dev_team[0].object_id
  }))
  depends_on = [
    module.cluster
  ]
}

resource "kubernetes_manifest" "jx_readonly_cluster_role" {
  count    = local.enable_cluster_user_rbac ? 1 : 0
  manifest = yamldecode(file("${path.module}/terraform-jx-cluster-aks/rbac/readonly/jx-readonly-cr.yaml"))
  depends_on = [
    module.cluster
  ]
}

resource "kubernetes_manifest" "jx_readonly_cluster_role_binding" {
  count = local.enable_cluster_user_rbac ? 1 : 0
  manifest = yamldecode(templatefile(
    "${path.module}/terraform-jx-cluster-aks/rbac/readonly/jx-readonly-crb.yaml",
    {
      group_object_id = data.azuread_group.jx_readonly_team[0].object_id
  }))
  depends_on = [
    module.cluster
  ]
}

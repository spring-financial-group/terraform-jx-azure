locals {
  # When azure_k8s_rbac_enabled = true, local_account_disabled = true and
  # kube_admin_config is empty. Fall back to the user kube_config (AAD-auth).
  active_kube_config     = var.azure_k8s_rbac_enabled ? azurerm_kubernetes_cluster.aks.kube_config[0] : azurerm_kubernetes_cluster.aks.kube_admin_config[0]
  active_kube_config_raw = var.azure_k8s_rbac_enabled ? azurerm_kubernetes_cluster.aks.kube_config_raw : azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "cluster_endpoint" {
  value = local.active_kube_config.host
}

output "client_certificate" {
  value = var.azure_k8s_rbac_enabled ? null : local.active_kube_config.client_certificate
}

output "client_key" {
  value = var.azure_k8s_rbac_enabled ? null : local.active_kube_config.client_key
}

output "ca_certificate" {
  value = local.active_kube_config.cluster_ca_certificate
}

output "kube_config_admin_raw" {
  value = local.active_kube_config_raw
}

output "kube_config_admin" {
  value = local.active_kube_config
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}
output "kubelet_identity_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}
output "kubelet_client_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity.0.client_id
}
output "kubernetes_cluster" {
  value = azurerm_kubernetes_cluster.aks
}
output "microsoft_defender_log_id" {
  value = length(azurerm_log_analytics_workspace.microsoft_defender) > 0 ? azurerm_log_analytics_workspace.microsoft_defender[0].id : null
}
output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
output "cluster_outbound_ip_addresses" {
  value = azurerm_public_ip.cluster_outbound[*].ip_address
}
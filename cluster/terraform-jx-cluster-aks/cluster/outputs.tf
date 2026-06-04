output "fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "cluster_endpoint" {
  value = try(azurerm_kubernetes_cluster.aks.kube_admin_config[0].host, null)
}

output "client_certificate" {
  value = try(azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_certificate, null)
}

output "client_key" {
  value = try(azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_key, null)
}

output "ca_certificate" {
  value = try(azurerm_kubernetes_cluster.aks.kube_admin_config[0].cluster_ca_certificate, null)
}
output "kube_config_admin_raw" {
  value = try(azurerm_kubernetes_cluster.aks.kube_admin_config_raw, null)
}
output "kube_config_admin" {
  value = try(azurerm_kubernetes_cluster.aks.kube_admin_config[0], null)
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

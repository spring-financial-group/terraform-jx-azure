output "registry_name" {
  value = module.registry.registry_name
}

output "resource_group_name" {
  value = module.registry.resource_group_name
}

output "kubelet_identity_id" {
  value = module.cluster.kubelet_identity_id
}
output "cluster_outbound_ip_addresses" {
  value = module.cluster.cluster_outbound_ip_addresses
}

output "cluster_subnet_id" {
  value = module.cluster.cluster_subnet_id
}

output "kubelet_client_id" {
  value = module.cluster.kubelet_client_id
}

output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

output "client_certificate" {
  value = module.cluster.client_certificate
}

output "client_key" {
  value = module.cluster.client_key
}

output "ca_certificate" {
  value = module.cluster.ca_certificate
}

output "kube_config_admin_raw" {
  value = module.cluster.kube_config_admin_raw
}

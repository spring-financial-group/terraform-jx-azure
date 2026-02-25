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

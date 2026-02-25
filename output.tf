output "registry_name" {
  value = module.cluster.registry_name
}

output "resource_group_name" {
  value = module.cluster.resource_group_name
}

output "cluster_outbound_ip_addresses" {
  value = module.cluster.cluster_outbound_ip_addresses
}

output "cluster_subnet_id" {
  value = module.cluster.cluster_subnet_id
}

output "registry_name" {
  value = module.cluster.registry_name
}

output "resource_group_name" {
  value = module.cluster.resource_group_name
}

output "cluster_outbound_ip_addresses" {
  value = ["51.11.169.142"] // Todo: Hook this up to the actual output from the cluster module
}

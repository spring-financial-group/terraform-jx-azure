output "registry_name" {
  value = module.registry.registry_name
}

output "resource_group_name" {
  value = module.registry.resource_group_name
}

output "kubelet_identity_id" {
  value = module.cluster.kubelet_identity_id
}

output "acr_registry_token_names" {
    value = module.registry.acr_registry_token_names
}

output "acr_registry_token_passwords" {
    value = module.registry.acr_registry_token_passwords
}
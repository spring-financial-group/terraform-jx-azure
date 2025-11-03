output "registry_name" {
  value = var.external_registry_url != "" ? var.external_registry_url : (var.use_existing_acr_name == null && length(azurerm_container_registry.acr) > 0 ? lower("${azurerm_container_registry.acr[0].name}.azurecr.io") : (length(data.azurerm_container_registry.acr_existing) > 0 ? data.azurerm_container_registry.acr_existing[0].name : ""))
}

output "admin_username" {
  value = var.external_registry_url != "" ? "" : (var.use_existing_acr_name == null && length(azurerm_container_registry.acr) > 0 ? azurerm_container_registry.acr[0].admin_username : (length(data.azurerm_container_registry.acr_existing) > 0 ? data.azurerm_container_registry.acr_existing[0].admin_username : ""))
}

output "admin_password" {
  value = var.external_registry_url != "" ? "" : (var.use_existing_acr_name == null && length(azurerm_container_registry.acr) > 0 ? azurerm_container_registry.acr[0].admin_password : (length(data.azurerm_container_registry.acr_existing) > 0 ? data.azurerm_container_registry.acr_existing[0].admin_password : ""))
}

output "resource_group_name" {
  value = var.external_registry_url != "" ? "" : (var.use_existing_acr_resource_group_name == null && length(azurerm_container_registry.acr) > 0 ? azurerm_container_registry.acr[0].resource_group_name : (length(data.azurerm_container_registry.acr_existing) > 0 ? data.azurerm_container_registry.acr_existing[0].resource_group_name : ""))
}

output "mqube_registry_token_name" {
  value     = var.enable_mqube_tech_acr_readonly ? local.container_registry_token_name : ""
  sensitive = true
}

output "mqube_registry_token_password" {
  value     = var.enable_mqube_tech_acr_readonly ? random_password.temp_token_password[0].result : ""
  sensitive = true
}

# output "mqube_registry_token_name" {
#   value     = var.enable_mqube_tech_acr_readonly ? azurerm_container_registry_token.acr_registry_token[0].name : ""
#   sensitive = true
# }

# output "mqube_registry_token_password" {
#   value     = var.enable_mqube_tech_acr_readonly ? azurerm_container_registry_token_password.acr_registry_token_password[0].password1[0].value : ""
#   sensitive = true
# }
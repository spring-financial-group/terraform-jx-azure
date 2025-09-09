output "oss_token_name" {
  value = length(azurerm_container_registry.oss_acr) > 0 ? azurerm_container_registry_token.oss_registry_token.name : ""
}

output "oss_token_password" {
  value = length(azurerm_container_registry.oss_acr) > 0 ? azurerm_container_registry_token_password.oss_registry_token_password.password1[0].value : ""
}
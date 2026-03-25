output "subnet_id" {
  value = azurerm_subnet.cluster_subnet.id
}

output "api_server_subnet_id" {
  value = var.enable_apiserver_vnet_integration ? azurerm_subnet.api_server_subnet[0].id : null
}

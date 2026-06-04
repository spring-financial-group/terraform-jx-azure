output "subnet_id" {
  value = azurerm_subnet.cluster_subnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.cluster.id
}

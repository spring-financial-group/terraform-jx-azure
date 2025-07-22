output "subnet_id" {
  value = azurerm_subnet.cluster_subnet.id
}

output "cluster_public_ip_address" {
  value = data.azurerm_public_ip.cluster_public_ip.ip_address
}

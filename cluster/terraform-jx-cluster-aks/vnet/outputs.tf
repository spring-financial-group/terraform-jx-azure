output "subnet_id" {
  value = azurerm_subnet.cluster_subnet.id
}

output "nat_gateway_public_ips" {
  value = azurerm_public_ip.nat_gateway[*].ip_address
}

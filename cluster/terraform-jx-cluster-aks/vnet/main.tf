
resource "azurerm_virtual_network" "cluster" {
  name                = var.network_name
  resource_group_name = var.resource_group
  location            = var.location
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "cluster_subnet" {
  name                              = var.subnet_name
  resource_group_name               = var.resource_group
  virtual_network_name              = azurerm_virtual_network.cluster.name
  address_prefixes                  = [var.subnet_cidr]
  private_endpoint_network_policies = "Enabled"
}

data "azurerm_public_ip" "cluster_public_ip" {
  resource_group_name = var.resource_group
  name                = "3d6a4d9a-0205-4b14-8c6b-105a080c12fb"
  depends_on        = [azurerm_subnet.cluster_subnet]
}

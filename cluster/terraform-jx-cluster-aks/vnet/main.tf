
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
  name                = "cluster-public-ip"
  depends_on        = [azurerm_subnet.cluster_subnet]
}

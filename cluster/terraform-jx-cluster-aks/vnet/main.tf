
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
  service_endpoints                 = ["Microsoft.Storage"]
}

// ----------------------------------------------------------------------------
// NAT Gateway for cluster outbound traffic
// ----------------------------------------------------------------------------

resource "azurerm_public_ip" "nat_gateway" {
  count               = var.cluster_managed_outbound_ip_count
  name                = "${var.cluster_name}-outbound-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_nat_gateway" "cluster" {
  name                    = "${var.cluster_name}-natgw"
  location                = var.location
  resource_group_name     = var.resource_group
  sku_name                = "Standard"
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout_in_minutes
}

resource "azurerm_nat_gateway_public_ip_association" "cluster" {
  count                = var.cluster_managed_outbound_ip_count
  nat_gateway_id       = azurerm_nat_gateway.cluster.id
  public_ip_address_id = azurerm_public_ip.nat_gateway[count.index].id
}

resource "azurerm_subnet_nat_gateway_association" "cluster" {
  subnet_id      = azurerm_subnet.cluster_subnet.id
  nat_gateway_id = azurerm_nat_gateway.cluster.id
}

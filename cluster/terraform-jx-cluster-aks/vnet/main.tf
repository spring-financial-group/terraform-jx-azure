
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

resource "azurerm_subnet" "api_server_subnet" {
  count                = var.enable_apiserver_vnet_integration ? 1 : 0
  name                 = "${var.subnet_name}-apiserver"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.cluster.name
  address_prefixes     = [var.api_server_subnet_cidr]

  delegation {
    name = "aks-api-server"
    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

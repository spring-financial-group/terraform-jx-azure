# tfsec:ignore:azure-container-limit-authorized-ips
# tfsec:ignore:azure-container-logging
# tfsec:ignore:azure-container-use-rbac-permissions
# tfsec:ignore:azure-container-configured-network-policy
resource "azurerm_kubernetes_cluster" "aks" {
  name                             = var.cluster_name
  sku_tier                         = var.sku_tier
  location                         = var.location
  resource_group_name              = var.resource_group_name
  node_resource_group              = var.node_resource_group_name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.cluster_version
  azure_policy_enabled             = var.azure_policy_bool
  cost_analysis_enabled            = var.cost_analysis_bool
  http_application_routing_enabled = false
  image_cleaner_interval_hours     = 48
  image_cleaner_enabled            = false

  node_os_upgrade_channel = var.enable_auto_upgrades ? "SecurityPatch" : "None"

  dynamic "maintenance_window_node_os" {
    for_each = var.enable_auto_upgrades ? [1] : []
    content {
      day_of_week = "Saturday"
      start_time  = "19:00"
      duration    = 4
      frequency   = "Weekly"
      interval    = 1
    }
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = false
    tenant_id          = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
  }

  microsoft_defender {
    log_analytics_workspace_id = var.microsoft_defender_log_id
  }

  dynamic "oms_agent" {
    for_each = var.enable_log_analytics ? [""] : []
    content {
      # enabled                    = var.enable_log_analytics
      log_analytics_workspace_id = var.enable_log_analytics ? azurerm_log_analytics_workspace.cluster[0].id : ""
    }
  }

  default_node_pool {
    name                 = "default"
    vm_size              = var.node_size
    vnet_subnet_id       = var.vnet_subnet_id
    node_count           = var.node_count
    min_count            = var.min_node_count
    max_count            = var.max_node_count
    orchestrator_version = var.orchestrator_version
    auto_scaling_enabled = var.max_node_count == null ? false : true
    upgrade_settings {
      max_surge = "25%"
    }
    zones                       = var.enable_node_zone_spanning ? ["1", "2", "3"] : var.node_zones
    temporary_name_for_rotation = "tempk8spool"
  }

  network_profile {
    network_plugin = var.cluster_network_model

    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"

    load_balancer_profile {
      managed_outbound_ip_count = 3
      idle_timeout_in_minutes = 10
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle { ignore_changes = [maintenance_window_node_os[0].utc_offset] }
}

resource "azurerm_kubernetes_cluster_node_pool" "mlnode" {
  count                       = var.ml_node_size == "" ? 0 : 1
  name                        = "mlnode"
  priority                    = var.use_spot_ml ? "Spot" : "Regular"
  eviction_policy             = var.use_spot_ml ? "Deallocate" : null
  spot_max_price              = var.use_spot_ml ? var.spot_max_price_ml : null
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vm_size                     = var.ml_node_size
  gpu_driver                  = var.gpu_driver_ml
  fips_enabled                = false
  vnet_subnet_id              = var.vnet_subnet_id
  node_count                  = var.use_spot_ml ? 0 : var.ml_node_count
  min_count                   = var.min_ml_node_count
  max_count                   = var.max_ml_node_count
  orchestrator_version        = var.orchestrator_version
  auto_scaling_enabled        = var.max_ml_node_count == null ? false : true
  node_taints                 = ["sku=gpu:NoSchedule"]
  node_labels                 = { key = "gpu_ready" }
  zones                       = var.enable_node_zone_spanning ? ["1", "2", "3"] : var.ml_node_zones
  temporary_name_for_rotation = "tempml"

  lifecycle { ignore_changes = [node_taints, node_count, node_labels] }
}

resource "azurerm_kubernetes_cluster_node_pool" "llmnode" {
  count                       = var.llm_node_size == "" ? 0 : 1
  name                        = "llmnode"
  priority                    = var.use_spot_llm ? "Spot" : "Regular"
  eviction_policy             = var.use_spot_llm ? "Deallocate" : null
  spot_max_price              = var.use_spot_llm ? var.spot_max_price_llm : null
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vm_size                     = var.llm_node_size
  fips_enabled                = false
  gpu_driver                  = var.gpu_driver_llm
  vnet_subnet_id              = var.vnet_subnet_id
  node_count                  = var.use_spot_llm ? 0 : var.llm_node_count
  min_count                   = var.min_llm_node_count
  max_count                   = var.max_llm_node_count
  orchestrator_version        = var.orchestrator_version
  auto_scaling_enabled        = var.max_llm_node_count == null ? false : true
  node_taints                 = ["sku=gpu:NoSchedule"]
  node_labels                 = { node = "llm", key = "gpu_ready" }
  zones                       = var.enable_node_zone_spanning ? ["1", "2", "3"] : var.llm_node_zones
  temporary_name_for_rotation = "templlm"

  lifecycle { ignore_changes = [node_taints, node_count, node_labels] }
}

resource "azurerm_kubernetes_cluster_node_pool" "buildnode" {
  count                       = var.build_node_size == "" ? 0 : 1
  name                        = "buildnode"
  priority                    = var.use_spot ? "Spot" : "Regular"
  eviction_policy             = var.use_spot ? "Deallocate" : null
  spot_max_price              = var.use_spot ? var.spot_max_price : null
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vm_size                     = var.build_node_size
  vnet_subnet_id              = var.vnet_subnet_id
  node_count                  = var.use_spot ? 0 : var.build_node_count
  min_count                   = var.min_build_node_count
  max_count                   = var.max_build_node_count
  orchestrator_version        = var.orchestrator_version
  auto_scaling_enabled        = var.max_build_node_count == null ? false : true
  node_taints                 = ["sku=build:NoSchedule"]
  zones                       = var.enable_node_zone_spanning ? ["1", "2", "3"] : var.build_node_zones
  temporary_name_for_rotation = "tempbuild"

  lifecycle { ignore_changes = [node_taints, node_count] }
}

resource "azurerm_kubernetes_cluster_node_pool" "infranode" {
  count                       = var.infra_node_size == "" ? 0 : 1
  name                        = "infranode"
  priority                    = var.use_spot_infra ? "Spot" : "Regular"
  eviction_policy             = var.use_spot_infra ? "Deallocate" : null
  spot_max_price              = var.use_spot_infra ? var.spot_max_price_infra : null
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vm_size                     = var.infra_node_size
  vnet_subnet_id              = var.vnet_subnet_id
  node_count                  = var.use_spot_infra ? 0 : var.infra_node_count
  min_count                   = var.min_infra_node_count
  max_count                   = var.max_infra_node_count
  orchestrator_version        = var.orchestrator_version
  auto_scaling_enabled        = var.max_infra_node_count == null ? false : true
  node_taints                 = ["sku=infra:NoSchedule"]
  node_labels                 = { node = "infra" }
  zones                       = var.enable_node_zone_spanning ? ["1", "2", "3"] : var.infra_node_zones
  temporary_name_for_rotation = "tempinfra"

  lifecycle { ignore_changes = [node_taints, node_count] }
}

resource "azurerm_kubernetes_cluster_node_pool" "mlbuildnode" {
  count                       = var.mlbuild_node_size == "" ? 0 : 1
  name                        = "mlbuildnode"
  priority                    = var.use_spot_mlbuild ? "Spot" : "Regular"
  eviction_policy             = var.use_spot_mlbuild ? "Deallocate" : null
  spot_max_price              = var.use_spot_mlbuild ? var.spot_max_price_mlbuild : null
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vm_size                     = var.mlbuild_node_size
  vnet_subnet_id              = var.vnet_subnet_id
  orchestrator_version        = var.orchestrator_version
  node_count                  = var.use_spot_mlbuild ? 0 : var.mlbuild_node_count
  min_count                   = var.min_mlbuild_node_count
  max_count                   = var.max_mlbuild_node_count
  auto_scaling_enabled        = var.max_mlbuild_node_count == null ? false : true
  node_taints                 = ["sku=mlbuild:NoSchedule"]
  node_labels                 = { key = "gpu_ready" }
  zones                       = var.enable_node_zone_spanning ? ["1", "2", "3"] : var.mlbuild_node_zones
  temporary_name_for_rotation = "tempmlbuild"

  lifecycle { ignore_changes = [node_taints, node_count, node_labels] }
}

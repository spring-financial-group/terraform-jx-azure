resource "azurerm_kubernetes_cluster" "aks" {
  name                             = var.cluster_name
  sku_tier                         = var.sku_tier
  location                         = var.location
  resource_group_name              = var.resource_group_name
  node_resource_group              = var.node_resource_group_name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.cluster_version
  azure_policy_enabled             = var.azure_policy_bool
  http_application_routing_enabled = false
  image_cleaner_interval_hours     = 48
  image_cleaner_enabled            = false

  automatic_upgrade_channel = var.enable_auto_upgrades ? "patch" : null

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

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.enable_auto_upgrades ? [1] : []
    content {
      day_of_week = "Friday"
      start_time  = "19:00"
      duration    = 4
      frequency   = "Weekly"
      interval    = 1
    }
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = false
    tenant_id          = var.tenant_id
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
    scale_down_mode      = "Deallocate"
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
    temporary_name_for_rotation = "temp${var.cluster_name}"
  }

  network_profile {
    network_plugin = var.cluster_network_model
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "mlnode" {
  count                 = var.ml_node_size == "" ? 0 : 1
  name                  = "mlnode"
  priority              = var.use_spot_ml ? "Spot" : "Regular"
  eviction_policy       = var.use_spot_ml ? "Deallocate" : null
  spot_max_price        = var.use_spot_ml ? var.spot_max_price_ml : null
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.ml_node_size
  vnet_subnet_id        = var.vnet_subnet_id
  node_count            = var.use_spot_ml ? 0 : var.ml_node_count
  min_count             = var.min_ml_node_count
  max_count             = var.max_ml_node_count
  orchestrator_version  = var.orchestrator_version
  auto_scaling_enabled  = var.max_ml_node_count == null ? false : true
  node_taints           = ["sku=gpu:NoSchedule"]
  node_labels           = { key = "gpu_ready" }

  lifecycle { ignore_changes = [node_taints, node_count, node_labels] }
}

resource "azurerm_kubernetes_cluster_node_pool" "buildnode" {
  count                 = var.build_node_size == "" ? 0 : 1
  name                  = "buildnode"
  priority              = var.use_spot ? "Spot" : "Regular"
  eviction_policy       = var.use_spot ? "Deallocate" : null
  spot_max_price        = var.use_spot ? var.spot_max_price : null
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.build_node_size
  vnet_subnet_id        = var.vnet_subnet_id
  node_count            = var.use_spot ? 0 : var.build_node_count
  min_count             = var.min_build_node_count
  max_count             = var.max_build_node_count
  orchestrator_version  = var.orchestrator_version
  auto_scaling_enabled  = var.max_build_node_count == null ? false : true
  node_taints           = ["sku=build:NoSchedule"]

  lifecycle { ignore_changes = [node_taints, node_count] }
}

resource "azurerm_kubernetes_cluster_node_pool" "infranode" {
  count                 = var.infra_node_size == "" ? 0 : 1
  name                  = "infranode"
  priority              = var.use_spot_infra ? "Spot" : "Regular"
  eviction_policy       = var.use_spot_infra ? "Deallocate" : null
  spot_max_price        = var.use_spot_infra ? var.spot_max_price_infra : null
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.infra_node_size
  vnet_subnet_id        = var.vnet_subnet_id
  node_count            = var.use_spot_infra ? 0 : var.infra_node_count
  min_count             = var.min_infra_node_count
  max_count             = var.max_infra_node_count
  orchestrator_version  = var.orchestrator_version
  auto_scaling_enabled  = var.max_infra_node_count == null ? false : true
  node_taints           = ["sku=infra:NoSchedule"]

  lifecycle { ignore_changes = [node_taints, node_count] }
}

resource "azurerm_kubernetes_cluster_node_pool" "mlbuildnode" {
  count                 = var.mlbuild_node_size == "" ? 0 : 1
  name                  = "mlbuildnode"
  priority              = var.use_spot_mlbuild ? "Spot" : "Regular"
  eviction_policy       = var.use_spot_mlbuild ? "Deallocate" : null
  spot_max_price        = var.use_spot_mlbuild ? var.spot_max_price_mlbuild : null
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.mlbuild_node_size
  vnet_subnet_id        = var.vnet_subnet_id
  orchestrator_version  = var.orchestrator_version
  node_count            = var.use_spot_mlbuild ? 0 : var.mlbuild_node_count
  min_count             = var.min_mlbuild_node_count
  max_count             = var.max_mlbuild_node_count
  auto_scaling_enabled  = var.max_mlbuild_node_count == null ? false : true
  node_taints           = ["sku=mlbuild:NoSchedule"]
  node_labels           = { key = "gpu_ready" }

  lifecycle { ignore_changes = [node_taints, node_count, node_labels] }
}

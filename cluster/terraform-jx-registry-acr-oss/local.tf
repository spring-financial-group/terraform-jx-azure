locals {
  anonymous_pull_enabled  = true
  admin_enabled           = true
  AcrPush_definition_name = "AcrPush"
  oss_registry_token_name = var.oss_registry_token_name != "" ? var.oss_registry_token_name : "token-${substr(join("", regexall("[A-Za-z0-9]", "mqube-oss")), 0, 38)}"
  oss_registry_scope_map_name = var.oss_registry_scope_map_name != "" ? var.oss_registry_scope_map_name : "scope-map-${substr(join("", regexall("[A-Za-z0-9]", "mqube-oss")), 0, 33)}"
}

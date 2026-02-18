jx_git_url                       = "https://github.com/spring-financial-group/JX3_Azure_Vault_Dev_Cluster"
cluster_name                     = "jx3-mqube-build"
location                         = "uksouth"
network_resource_group_name      = "mqubejx3build-network_rsg"
cluster_resource_group_name      = "mqubejx3build-cluster_rsg"
cluster_node_resource_group_name = "jx3build-cluster-nodes-rsg"
network_name                     = "jx3-build-networks"
apex_domain_integration_enabled  = true
apex_domain                      = "mqube.build"
subdomain                        = "jx"
apex_resource_group_name         = "jx3build-apex-dns-rsg"
dns_resource_group_name          = "jx3build-dns-rsg"
key_vault_enabled                = false
key_vault_resource_group_name    = "jx3key-vault-rsg"
key_vault_name                   = "k8secrets-vault"
cluster_version                  = "1.32.9"
orchestrator_version             = "1.32.9"
azure_policy_bool                = false
enable_cluster_user_rbac         = true
cost_analysis_bool               = true
acr_enabled                      = true
install_kuberhealthy             = true
enable_acr_chart_registry        = true
enable_mqube_tech_acr_readonly   = false
dns_resources_enabled            = true
default_suk_bool                 = true
enable_defender_analytics        = true
enable_auto_upgrades             = true
oss_acr_enabled                  = true
oss_acr_pull_enabled             = false
enable_node_zone_spanning        = false
cluster_managed_outbound_ip_count = 2

# Machines
min_node_count = 5
max_node_count = 50
node_size      = "Standard_D8s_v5"


# Ml nodes
use_spot_ml       = true
ml_node_size      = "Standard_NV24s_v3"
min_ml_node_count = 2
max_ml_node_count = 6

# LLM nodes
use_spot_llm       = true
llm_node_size      = "Standard_NC40ads_H100_v5"
min_llm_node_count = 0
max_llm_node_count = 2

# Build Spot Nodes
use_spot             = true
build_node_size      = "Standard_D8s_v5"
min_build_node_count = 1
max_build_node_count = 8

#Infra Node
use_spot_infra       = false
infra_node_size      = "Standard_D8s_v5"
min_infra_node_count = 3
max_infra_node_count = 6

# MLbuild Node
use_spot_mlbuild       = true
mlbuild_node_size      = "Standard_NC4as_T4_v3"
min_mlbuild_node_count = 0
max_mlbuild_node_count = 5

# Bot stuff in now in terraform

# External registry not used at the moment
external_registry_url = ""
oss_registry_name     = "mqubeoss"
oss_registry_resource_group = "rg-registry-jx3-mqube-build"

server_side_apply_enabled = false

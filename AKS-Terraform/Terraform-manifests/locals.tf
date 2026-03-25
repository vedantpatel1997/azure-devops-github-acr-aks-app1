locals {
  environment_slug = lower(var.environment)
  location_slug    = lower(replace(var.location, " ", ""))
  # instance_suffix           = "01"
  name_suffix               = "${var.organization_name}-aks-${local.environment_slug}-${local.location_slug}"
  cluster_suffix            = "${var.organization_name}-${local.environment_slug}-${local.location_slug}"
  node_pool_environment_tag = substr(replace(local.environment_slug, "-", ""), 0, 3)
  windows_node_pool_tag     = substr(replace(local.environment_slug, "-", ""), 0, 2)

  resource_group_name                  = "rg-${local.name_suffix}"
  cluster_name                         = "aks-${local.cluster_suffix}"
  node_resource_group_name             = "rg-${local.name_suffix}-nodes"
  log_analytics_workspace_name         = "log-${local.name_suffix}"
  cluster_admin_group_name             = "grp-aksadmin-${local.cluster_name}"
  virtual_network_name                 = "vnet-${local.name_suffix}"
  system_subnet_name                   = "snet-${local.name_suffix}-system"
  linux_user_subnet_name               = "snet-${local.name_suffix}-linux"
  windows_user_subnet_name             = "snet-${local.name_suffix}-windows"
  system_node_pool_name                = substr("sys${local.node_pool_environment_tag}01", 0, 12)
  linux_user_node_pool_name            = substr("lin${local.node_pool_environment_tag}01", 0, 12)
  windows_user_node_pool_name          = substr("win${local.windows_node_pool_tag}1", 0, 6)
  system_node_pool_rotation_name       = substr("syr${local.node_pool_environment_tag}01", 0, 12)
  linux_user_node_pool_rotation_name   = substr("lir${local.node_pool_environment_tag}01", 0, 12)
  windows_user_node_pool_rotation_name = substr("wir${local.windows_node_pool_tag}1", 0, 6)

  common_tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      owner       = var.organization_name
      platform    = "aks"
      project     = "aks-terraform"
    },
    var.additional_tags,
  )

  system_node_pool_labels = {
    "environment"   = var.environment
    "nodepool-os"   = "linux"
    "nodepool-type" = "system"
    "workload"      = "system-apps"
  }

  linux_user_node_pool_labels = {
    "environment"   = var.environment
    "nodepool-os"   = "linux"
    "nodepool-type" = "user"
    "workload"      = "java-apps"
  }

  windows_user_node_pool_labels = {
    "environment"   = var.environment
    "nodepool-os"   = "windows"
    "nodepool-type" = "user"
    "workload"      = "dotnet-apps"
  }

  system_node_pool_tags = merge(
    local.common_tags,
    {
      node_pool = local.system_node_pool_name
      os        = "linux"
      role      = "system"
      workload  = "system-apps"
    },
  )

  linux_user_node_pool_tags = merge(
    local.common_tags,
    {
      node_pool = local.linux_user_node_pool_name
      os        = "linux"
      role      = "user"
      workload  = "java-apps"
    },
  )

  windows_user_node_pool_tags = merge(
    local.common_tags,
    {
      node_pool = local.windows_user_node_pool_name
      os        = "windows"
      role      = "user"
      workload  = "dotnet-apps"
    },
  )
}

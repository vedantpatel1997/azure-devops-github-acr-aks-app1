locals {
  environment_compact          = substr(replace(var.environment, "-", ""), 0, 4)
  name_prefix                  = lower("${var.organization_name}-${var.environment}")
  resource_group_name          = "rg-${local.name_prefix}-aks"
  cluster_name                 = "${local.resource_group_name}-cluster"
  node_resource_group_name     = "${local.resource_group_name}-nrg"
  log_analytics_workspace_name = "lws-${local.name_prefix}-aks-${random_pet.aks_suffix.id}"
  cluster_admin_group_name     = "grp-aks-admins-${local.name_prefix}"
  virtual_network_name         = "vnet-${local.name_prefix}-aks"
  system_subnet_name           = "snet-${local.name_prefix}-aks-system"
  linux_user_subnet_name       = "snet-${local.name_prefix}-aks-linux"
  windows_user_subnet_name     = "snet-${local.name_prefix}-aks-windows"
  system_node_pool_name        = substr("aks${local.environment_compact}sys", 0, 12)
  linux_user_node_pool_name    = substr("aks${local.environment_compact}lin", 0, 12)
  windows_user_node_pool_name  = substr("aks${local.environment_compact}win", 0, 12)

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

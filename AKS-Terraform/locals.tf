locals {
  name_prefix              = lower("${var.organization_name}-${var.environment}")
  resource_group_name      = "rg-${local.name_prefix}-aks"
  cluster_name             = "${local.resource_group_name}-cluster"
  node_resource_group_name = "${local.resource_group_name}-nrg"

  common_tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      owner       = var.organization_name
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
      node_pool = "systempool"
      os        = "linux"
      role      = "system"
      workload  = "system-apps"
    },
  )

  linux_user_node_pool_tags = merge(
    local.common_tags,
    {
      node_pool = "linux101"
      os        = "linux"
      role      = "user"
      workload  = "java-apps"
    },
  )

  windows_user_node_pool_tags = merge(
    local.common_tags,
    {
      node_pool = "win101"
      os        = "windows"
      role      = "user"
      workload  = "dotnet-apps"
    },
  )
}

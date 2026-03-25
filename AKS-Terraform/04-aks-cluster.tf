resource "azurerm_kubernetes_cluster" "aks" {
  name                    = local.cluster_name
  location                = azurerm_resource_group.aks.location
  resource_group_name     = azurerm_resource_group.aks.name
  kubernetes_version      = var.kubernetes_version
  dns_prefix              = local.cluster_name
  node_resource_group     = local.node_resource_group_name
  node_os_upgrade_channel = "NodeImage"
  sku_tier                = "Free"
  support_plan            = "KubernetesOfficial"

  default_node_pool {
    name                        = local.system_node_pool_name
    vm_size                     = var.system_node_pool_vm_size
    node_count                  = 1
    min_count                   = 1
    max_count                   = 3
    auto_scaling_enabled        = true
    orchestrator_version        = var.kubernetes_version
    zones                       = var.system_node_pool_zones
    type                        = "VirtualMachineScaleSets"
    vnet_subnet_id              = azurerm_subnet.system_node_pool.id
    temporary_name_for_rotation = "syspooltmp"
    node_labels                 = local.system_node_pool_labels
    tags                        = local.system_node_pool_tags

    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  azure_policy_enabled              = true
  oidc_issuer_enabled               = true
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [azuread_group.cluster_admins.object_id]
    azure_rbac_enabled     = false
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  linux_profile {
    admin_username = var.linux_admin_username

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.aks_service_cidr
    dns_service_ip    = var.aks_dns_service_ip
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      windows_profile[0].admin_password,
    ]
  }

  tags = local.common_tags
}

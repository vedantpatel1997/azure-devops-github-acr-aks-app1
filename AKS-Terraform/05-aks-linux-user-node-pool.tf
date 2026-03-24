# Dedicated Linux user node pool for Linux application workloads.
resource "azurerm_kubernetes_cluster_node_pool" "linux_user" {
  name                  = "linux101"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.linux_user_node_pool_vm_size
  node_count            = 1
  min_count             = 1
  max_count             = 3
  mode                  = "User"
  os_type               = "Linux"
  os_disk_size_gb       = 30
  priority              = "Regular"
  orchestrator_version  = var.kubernetes_version
  auto_scaling_enabled  = true
  zones                 = var.user_node_pool_zones
  node_labels           = local.linux_user_node_pool_labels
  tags                  = local.linux_user_node_pool_tags

  upgrade_settings {
    max_surge                     = "10%"
    drain_timeout_in_minutes      = 0
    node_soak_duration_in_minutes = 0
  }

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}

output "location" {
  description = "Azure region where the platform resources are deployed."
  value       = azurerm_resource_group.aks.location
}

output "resource_group_id" {
  description = "Resource ID of the AKS resource group."
  value       = azurerm_resource_group.aks.id
}

output "resource_group_name" {
  description = "Name of the AKS resource group."
  value       = azurerm_resource_group.aks.name
}

output "cluster_name" {
  description = "Name of the managed AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_id" {
  description = "Resource ID of the managed AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "virtual_network_name" {
  description = "Name of the custom virtual network hosting the AKS node pools."
  value       = azurerm_virtual_network.aks.name
}

output "virtual_network_id" {
  description = "Resource ID of the custom virtual network hosting the AKS node pools."
  value       = azurerm_virtual_network.aks.id
}

output "configured_kubernetes_version" {
  description = "Pinned Kubernetes version configured for the cluster and node pools."
  value       = var.kubernetes_version
}

output "latest_version" {
  description = "Latest GA Kubernetes version currently available in the target Azure region."
  value       = data.azurerm_kubernetes_service_versions.latest.latest_version
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace used by AKS monitoring."
  value       = azurerm_log_analytics_workspace.aks.id
}

output "lws_id" {
  description = "Backward-compatible alias for the Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.aks.id
}

output "aks_admin_group_object_id" {
  description = "Object ID of the Microsoft Entra group configured as the AKS admin group."
  value       = azuread_group.cluster_admins.object_id
}

output "aks_admins" {
  description = "Backward-compatible alias for the AKS admin group object ID."
  value       = azuread_group.cluster_admins.object_id
}

output "client_certificate" {
  description = "Client certificate from the cluster kubeconfig."
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "kube_config" {
  description = "Raw kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "linux_user_node_pool_id" {
  description = "Resource ID of the Linux user node pool."
  value       = try(azurerm_kubernetes_cluster_node_pool.linux_user[0].id, null)
}

output "system_node_pool_subnet_id" {
  description = "Resource ID of the subnet assigned to the AKS system node pool."
  value       = azurerm_subnet.system_node_pool.id
}

output "linux_user_node_pool_subnet_id" {
  description = "Resource ID of the subnet assigned to the Linux user node pool."
  value       = try(azurerm_subnet.linux_user_node_pool[0].id, null)
}

output "windows_user_node_pool_subnet_id" {
  description = "Resource ID of the subnet assigned to the Windows user node pool."
  value       = try(azurerm_subnet.windows_user_node_pool[0].id, null)
}

output "windows_user_node_pool_id" {
  description = "Resource ID of the Windows user node pool."
  value       = try(azurerm_kubernetes_cluster_node_pool.windows_user[0].id, null)
}

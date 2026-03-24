resource "azuread_group" "cluster_admins" {
  display_name     = "grp-aks-admins-${local.name_prefix}"
  description      = "Microsoft Entra group for AKS cluster administrators on ${local.cluster_name}."
  security_enabled = true
}

resource "azuread_group_member" "cluster_admin_user" {
  group_object_id  = azuread_group.cluster_admins.object_id
  member_object_id = data.azuread_user.cluster_admin.object_id
}

# Grants the admin group permission to retrieve the cluster user kubeconfig.
resource "azurerm_role_assignment" "cluster_user_credentials" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_group.cluster_admins.object_id
  principal_type       = "Group"
}

data "azurerm_kubernetes_service_versions" "latest" {
  location        = var.location
  include_preview = false
}

data "azuread_user" "cluster_admin" {
  user_principal_name = var.aks_admin_user_principal_name
}

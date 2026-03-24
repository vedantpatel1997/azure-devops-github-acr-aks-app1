resource "azurerm_log_analytics_workspace" "aks" {
  name                = "lws-${local.name_prefix}-${random_pet.aks_suffix.id}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.common_tags
}

resource "azurerm_virtual_network" "aks" {
  name                = local.virtual_network_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = var.aks_vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "system_node_pool" {
  name                 = local.system_subnet_name
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = var.system_node_pool_subnet_address_prefixes
}

resource "azurerm_subnet" "linux_user_node_pool" {
  name                 = local.linux_user_subnet_name
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = var.linux_user_node_pool_subnet_address_prefixes
}

resource "azurerm_subnet" "windows_user_node_pool" {
  name                 = local.windows_user_subnet_name
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = var.windows_user_node_pool_subnet_address_prefixes
}

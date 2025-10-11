resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "vnets" {
  for_each = var.virtual_networks

  source              = "./modules/vnet"
  vnet_name           = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = each.value.address_space
  subnets             = each.value.subnets
}
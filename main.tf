resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_string" "sa_name" {
  length  = 16
  special = false
  upper   = false
}

resource "azurerm_storage_account" "cloudshell_storage" {
  name                     = "st${random_string.sa_name.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_managed_disk" "disks" {
  for_each = var.managed_disks

  name                 = each.value.name
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = each.value.sku
  create_option        = "Empty"
  disk_size_gb         = each.value.size
}
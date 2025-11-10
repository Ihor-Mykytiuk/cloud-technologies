resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# data "azurerm_policy_definition" "require_tag" {
#   display_name = "Require a tag and its value on resources"
# }
#
# resource "azurerm_resource_group_policy_assignment" "require_tag" {
#   name                  = "require-cost-center-tag"
#   description           = "Require Cost Center tag and its value on all resources in the resource group"
#   resource_group_id     = azurerm_resource_group.rg.id
#   policy_definition_id  = data.azurerm_policy_definition.require_tag.id
#   enforce               = true
#
#   parameters = jsonencode({
#     "tagName" = { 
#         value = keys(var.tags)[0] 
#     },
#     "tagValue" = {
#         value = values(var.tags)[0]
#     }
#   })
# }

data "azurerm_policy_definition" "inherit_tag" {
  display_name = "Inherit a tag from the resource group if missing"
}

resource "azurerm_resource_group_policy_assignment" "inherit_tag" {
  name                 = "inherit-cost-center-tag"
  description          = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  resource_group_id    = azurerm_resource_group.rg.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag.id
  enforce              = true
  location = var.location

  parameters = jsonencode({
    "tagName" = {
      value = keys(var.tags)[0] 
    }
  })

  identity {
    type = "SystemAssigned"
  }

}

resource "random_string" "sa_name" {
  length  = 16
  special = false
  upper   = false
}

resource "azurerm_storage_account" "testsa" {
  name                     = "st${random_string.sa_name.result}" 
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_lock" "rg_lock" {
  name       = var.lock_name
  scope      = azurerm_resource_group.rg.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}
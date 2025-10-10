resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag and its value on resources"
}

resource "azurerm_resource_group_policy_assignment" "require_tag" {
  name                  = "require-cost-center-tag"
  description           = "Require Cost Center tag and its value on all resources in the resource group"
  resource_group_id     = azurerm_resource_group.rg.id
  policy_definition_id  = data.azurerm_policy_definition.require_tag.id
  enforce               = true

  parameters = jsonencode({
    "tagName" = { 
        value = keys(var.tags)[0] 
    },
    "tagValue" = {
        value = values(var.tags)[0]
    }
})
}
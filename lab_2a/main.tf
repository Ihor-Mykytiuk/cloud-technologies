terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

resource "azurerm_management_group" "az104_mg1" {
  name         = var.management_group_id
  display_name = var.management_group_display_name
}

resource "azuread_group" "helpdesk" {
  display_name     = "helpdesk"
  description      = "Help Desk group"
  security_enabled = true
}

data "azurerm_role_definition" "vm_contributor" {
  name = "Virtual Machine Contributor"
}

resource "azurerm_role_assignment" "vm_contributor_assignment" {
  scope                = azurerm_management_group.az104_mg1.id
  role_definition_id   = data.azurerm_role_definition.vm_contributor.id
  principal_id         = azuread_group.helpdesk.object_id
}

data "azurerm_role_definition" "support_request_contributor" {
  name = "Support Request Contributor"
}

resource "azurerm_role_definition" "custom_support_request" {
  name        = var.custom_role_name
  scope       = azurerm_management_group.az104_mg1.id
  description = "A custom contributor role for support requests."

  permissions {
    actions = data.azurerm_role_definition.support_request_contributor.permissions[0].actions
    not_actions = concat(
        data.azurerm_role_definition.support_request_contributor.permissions[0].not_actions,
        ["Microsoft.Support/register/action"]
    )
  }

  assignable_scopes = [
    azurerm_management_group.az104_mg1.id,
  ]
}
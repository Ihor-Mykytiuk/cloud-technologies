terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azuread" {
}

data "azuread_domains" "primary" {
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "azuread_user" "az104_user1" {
  user_principal_name = "az104-user1@${data.azuread_domains.primary.domains[0].domain_name}"
  display_name        = "az104-user1"
  password            = random_password.password.result
  force_password_change = true
  job_title           = "IT Lab Administrator"
  department          = "IT"
  usage_location      = "US"
}

resource "azuread_invitation" "external_user" {
  user_email_address    = var.external_user_email
  user_display_name     = var.external_user_display_name
  redirect_url          = "https://portal.azure.com"
  message {
    body = "Welcome to Azure and our group project"
  }
}

resource "azuread_group" "it_lab_administrators" {
  display_name     = "IT Lab Administrators"
  description      = "Administrators that manage the IT lab"
  security_enabled = true
}

resource "azuread_group_member" "internal_member" {
  group_object_id  = azuread_group.it_lab_administrators.object_id
  member_object_id = azuread_user.az104_user1.object_id
}

resource "azuread_group_member" "guest_member" {
  group_object_id  = azuread_group.it_lab_administrators.object_id
  member_object_id = azuread_invitation.external_user.user_id
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_storage_account" "storage" {
  name                     = "az104-lab7${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  account_kind             = "StorageV2"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = [chomp(data.http.my_public_ip.response_body)]
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = []
  }
}

resource "azurerm_storage_management_policy" "lifecycle_policy" {
  storage_account_id = azurerm_storage_account.storage.id

  rule {
    name    = "Movetocool"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
}
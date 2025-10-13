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
  name                     = "az104lab7${random_string.storage_suffix.result}"
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

resource "azurerm_storage_container" "data_container" {
  name                  = "data"
  storage_account_id = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_storage_container_immutability_policy" "immutability_policy" {
  storage_container_resource_manager_id = azurerm_storage_container.data_container.id
  immutability_period_in_days = 180
}

resource "time_static" "today" {
}

data "azurerm_storage_account_sas" "sas_token" {
  connection_string = azurerm_storage_account.storage.primary_connection_string
  https_only        = true

  resource_types {
    object    = true
    service   = false
    container = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timeadd(time_static.today.rfc3339, "-24h")
  expiry = timeadd(time_static.today.rfc3339, "24h")

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}
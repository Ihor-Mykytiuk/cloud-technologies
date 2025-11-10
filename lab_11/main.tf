resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

locals {
  vnet_name             = "az104-vnet"
  subnet_name           = "subnet0"
  public_ip_name        = "az104-pip0"
  nsg_name              = "az104-nsg01"
  nic_name              = "az104-nic0"
  storage_account_name  = "az10411"
  vm_name               = "az104-vm0"
  ip_configuration_name = "ipconfig1"
  nsg_rule_name         = "default-allow-rdp"
  
  vm_extension_name             = "AzureMonitorWindowsAgent"
  la_workspace_name             = "az104-laworkspace"
  dcr_name                      = "az104-dcr"
  dcr_dest_name                 = "VMInsightsPerf-Logs-Dest"
  dcr_perf_counters_name        = "VMInsightsPerfCounters"
  dcr_assoc_name                = "dcr-vm-assoc"
  action_group_name             = "Alert the operations team"
  vm_deleted_name               = "VM was deleted"
  suppression_rule_name         = "planned-maintenance"
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_public_ip" "pip" {
  name                = local.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = local.nsg_rule_name
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = local.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = local.ip_configuration_name
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "sa_bootdiag" {
  name                     = "${local.storage_account_name}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = local.vm_name
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sa_bootdiag.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "ama" {
  name                       = local.vm_extension_name
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.21"
  auto_upgrade_minor_version = true
}

resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                = local.la_workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "insights_dcr" {
  name                = local.dcr_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  description         = "Data collection rule for VM Insights for ${local.vm_name}"

  destinations {
    log_analytics {
      name                  = local.dcr_dest_name
      workspace_resource_id = azurerm_log_analytics_workspace.la_workspace.id
    }
  }

  data_sources {
    performance_counter {
      name                          = local.dcr_perf_counters_name
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = [local.dcr_dest_name]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc" {
  name                    = local.dcr_assoc_name
  target_resource_id      = azurerm_windows_virtual_machine.vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.insights_dcr.id
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = local.action_group_name
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "AlertOpsTeam"

  email_receiver {
    name          = local.vm_deleted_name
    email_address = var.alert_email
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_monitor_activity_log_alert" "alert_rule" {
  name                = local.vm_deleted_name
  description         = "A VM in your resource group was deleted"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [data.azurerm_subscription.current.id]
  location = "global"


  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/delete"
    status         = "Succeeded"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}


resource "azurerm_monitor_alert_processing_rule_suppression" "suppression_rule" {
  name                = local.suppression_rule_name
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Suppress notifications during planned maintenance."

  schedule {
    effective_from = "2025-10-17T22:00:00"
    effective_until = "2025-10-18T07:00:00"
    time_zone      = "FLE Standard Time"
  }
}
# --- TASK 1: Provision Infrastructure (VM & Network) ---
# Розгортання мережі, підмережі, IP, NSG та віртуальної машини

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

locals {
  vnet_name          = "az104-10-vnet"
  subnet_name        = "subnet0"
  pip_name           = "az104-10-pip0"
  nsg_name           = "az104-10-nsg01"
  nic_name           = "az104-10-nic0"
  vm_name            = "az104-10-vm0"
  rsv_name           = "az104-rsv-region1"
  backup_policy_name = "az104-backup"
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
  
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_public_ip" "pip" {
  name                = local.pip_name
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
    name                       = "default-allow-rdp"
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
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  depends_on = [ 
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet,
    azurerm_network_security_group.nsg
   ]
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
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
}

# --- TASK 2: Create Recovery Services Vault (Primary) ---
# Створення основного сховища в Region 1

resource "azurerm_recovery_services_vault" "rsv" {
  name                = local.rsv_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  storage_mode_type   = "GeoRedundant"
  soft_delete_enabled = true
}

# --- TASK 3: Configure Azure VM Backup ---
# Створення політики та увімкнення бекапу

resource "azurerm_backup_policy_vm" "backup_policy" {
  name                = local.backup_policy_name
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "00:00"
  }

  retention_daily {
    count = 14
  }

  instant_restore_retention_days = 2

  depends_on = [
    azurerm_recovery_services_vault.rsv
  ]
}

resource "azurerm_backup_protected_vm" "vm_backup" {
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  source_vm_id        = azurerm_windows_virtual_machine.vm.id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy.id

  depends_on = [
    azurerm_windows_virtual_machine.vm,
    azurerm_backup_policy_vm.backup_policy
  ]
}

# --- TASK 4: Monitor Azure Backup ---
# Створення Storage Account та діагностичних налаштувань

resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "sa_diag" {
  name                     = "az104lab10diag${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_diagnostic_setting" "rsv_diag" {
  name               = "Logs and Metrics to storage"
  target_resource_id = azurerm_recovery_services_vault.rsv.id
  storage_account_id = azurerm_storage_account.sa_diag.id

  enabled_log {
    category = "AzureBackupReport"
  }

  enabled_log {
    category = "AzureSiteRecoveryJobs"
  }
  enabled_log {
    category = "AzureSiteRecoveryEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# --- TASK 5: Enable Virtual Machine Replication (PREPARATION) ---
# Підготовка ресурсів для реплікації (RG та Vault у другому регіоні).
# Саму реплікацію (Fabrics, Containers, Policy) закоментовано для ручного налаштування.

locals {
  rg_secondary_name        = "az104-rg-region2"
  rsv_secondary_name       = "az104-rsv-region2"
  primary_fabric_name      = "primary-fabric"
  secondary_fabric_name    = "secondary-fabric"
  primary_container_name   = "primary-protection-container"
  secondary_container_name = "secondary-protection-container"
  replication_policy_name  = "replication-policy"
  container_mapping_name   = "container-mapping"
  vnet_secondary_name      = "az104-10-vnet-secondary"
  network_mapping_name     = "network_mapping"
}

# ЦІ ДВА РЕСУРСИ ЗАЛИШАЄМО АКТИВНИМИ! 
# Вони потрібні, щоб при ручному налаштуванні ти міг вибрати готовий Vault.
resource "azurerm_resource_group" "rg_secondary" {
  name     = local.rg_secondary_name
  location = var.secondary_location
}

resource "azurerm_recovery_services_vault" "rsv_secondary" {
  name                = local.rsv_secondary_name
  location            = azurerm_resource_group.rg_secondary.location
  resource_group_name = azurerm_resource_group.rg_secondary.name
  sku                 = "Standard"
}

# --- КОД ДЛЯ АВТОМАТИЧНОЇ РЕПЛІКАЦІЇ (ЗАКЕМЕНТОВАНО) ---
# Цю частину ти виконаєш вручну на порталі Azure (VM -> Disaster Recovery)

/*
resource "azurerm_site_recovery_fabric" "primary_fabric" {
  name                = local.primary_fabric_name
  resource_group_name = azurerm_resource_group.rg_secondary.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_secondary.name
  location            = azurerm_resource_group.rg.location
  depends_on = [
    azurerm_recovery_services_vault.rsv_secondary
  ]
}

resource "azurerm_site_recovery_fabric" "secondary_fabric" {
  name                = local.secondary_fabric_name
  resource_group_name = azurerm_resource_group.rg_secondary.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv_secondary.name
  location            = azurerm_resource_group.rg_secondary.location

  depends_on = [
    azurerm_recovery_services_vault.rsv_secondary
  ]
}

resource "azurerm_site_recovery_protection_container" "primary_container" {
  name                 = local.primary_container_name
  resource_group_name  = azurerm_resource_group.rg_secondary.name
  recovery_vault_name  = azurerm_recovery_services_vault.rsv_secondary.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary_fabric.name

  depends_on = [
    azurerm_site_recovery_fabric.primary_fabric,
    azurerm_recovery_services_vault.rsv_secondary
  ]
}

resource "azurerm_site_recovery_protection_container" "secondary_container" {
  name                 = local.secondary_container_name
  resource_group_name  = azurerm_resource_group.rg_secondary.name
  recovery_vault_name  = azurerm_recovery_services_vault.rsv_secondary.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary_fabric.name

  depends_on = [
    azurerm_site_recovery_fabric.secondary_fabric,
    azurerm_recovery_services_vault.rsv_secondary
  ]
}

resource "azurerm_site_recovery_replication_policy" "replication_policy" {
  name                                                 = local.replication_policy_name
  resource_group_name                                  = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.rsv_secondary.name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60

  depends_on = [
    azurerm_site_recovery_protection_container.primary_container,
    azurerm_recovery_services_vault.rsv_secondary
  ]
}

resource "azurerm_site_recovery_protection_container_mapping" "container_mapping" {
  name                                      = local.container_mapping_name
  resource_group_name                       = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                       = azurerm_recovery_services_vault.rsv_secondary.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary_fabric.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary_container.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary_container.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.replication_policy.id
  depends_on = [
    azurerm_recovery_services_vault.rsv_secondary,
    azurerm_site_recovery_fabric.primary_fabric,
    azurerm_site_recovery_protection_container.primary_container,
    azurerm_site_recovery_protection_container.secondary_container,
    azurerm_site_recovery_replication_policy.replication_policy
  ]
}

resource "azurerm_virtual_network" "vnet_secondary" {
  name                = local.vnet_secondary_name
  resource_group_name = azurerm_resource_group.rg_secondary.name
  location            = azurerm_resource_group.rg_secondary.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_site_recovery_network_mapping" "network_mapping" {
  name                        = local.network_mapping_name
  resource_group_name         = azurerm_resource_group.rg_secondary.name
  recovery_vault_name         = azurerm_recovery_services_vault.rsv_secondary.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary_fabric.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary_fabric.name
  source_network_id           = azurerm_virtual_network.vnet.id
  target_network_id           = azurerm_virtual_network.vnet_secondary.id

  depends_on = [
    azurerm_recovery_services_vault.rsv_secondary,
    azurerm_site_recovery_fabric.primary_fabric,
    azurerm_site_recovery_fabric.secondary_fabric,
    azurerm_virtual_network.vnet,
    azurerm_virtual_network.vnet_secondary,
  ]
}

resource "azurerm_site_recovery_replicated_vm" "replicated_vm" {
  name                                      = "${azurerm_windows_virtual_machine.vm.name}-replication"
  resource_group_name                       = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                       = azurerm_recovery_services_vault.rsv_secondary.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary_fabric.name
  source_vm_id                              = azurerm_windows_virtual_machine.vm.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.replication_policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary_container.name

  target_resource_group_id                = azurerm_resource_group.rg_secondary.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary_fabric.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary_container.id

  managed_disk {
    disk_id                    = azurerm_windows_virtual_machine.vm.os_managed_disk_id
    staging_storage_account_id = azurerm_storage_account.sa_diag.id
    target_resource_group_id   = azurerm_resource_group.rg_secondary.id
    target_disk_type           = "Standard_LRS"
    target_replica_disk_type   = "Standard_LRS"
  }

  target_network_id = azurerm_virtual_network.vnet_secondary.id

  depends_on = [
    azurerm_recovery_services_vault.rsv_secondary,
    azurerm_site_recovery_fabric.primary_fabric,
    azurerm_site_recovery_fabric.secondary_fabric,
    azurerm_site_recovery_protection_container.primary_container,
    azurerm_site_recovery_protection_container.secondary_container,
    azurerm_site_recovery_replication_policy.replication_policy,
    azurerm_site_recovery_network_mapping.network_mapping,
    azurerm_site_recovery_protection_container_mapping.container_mapping,
    azurerm_windows_virtual_machine.vm,
    azurerm_virtual_network.vnet_secondary,
    azurerm_storage_account.sa_diag
  ]
}
*/
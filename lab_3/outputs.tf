output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "cloud_shell_storage_account_name" {
  description = "Name of the storage account created for Cloud Shell."
  value       = azurerm_storage_account.cloudshell_storage.name
}

output "created_disks" {
  description = "Information about the created managed disks."
  value = {
    for key, disk in azurerm_managed_disk.disks : key => {
      name = disk.name
      id   = disk.id
      sku  = disk.storage_account_type
    }
  }
}
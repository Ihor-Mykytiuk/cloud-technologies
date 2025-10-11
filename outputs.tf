output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "cloud_shell_storage_account_name" {
  description = "Name of the storage account created for Cloud Shell."
  value       = azurerm_storage_account.cloudshell_storage.name
}
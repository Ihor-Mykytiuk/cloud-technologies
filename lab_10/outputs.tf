output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = var.location
}

output "virtual_machine_name" {
  description = "The name of the created virtual machine"
  value       = azurerm_windows_virtual_machine.vm.name
}

output "virtual_machine_public_ip" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_public_ip.pip.ip_address
}

output "recovery_services_vault_id" {
  description = "The ID of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.rsv.id
}

output "diagnostics_storage_account_name" {
  description = "The name of the storage account for diagnostics"
  value       = azurerm_storage_account.sa_diag.name
}

output "secondary_resource_group_name" {
  description = "The name of the secondary resource group for disaster recovery"
  value       = azurerm_resource_group.rg_secondary.name
}

output "secondary_location" {
  description = "The Azure region for disaster recovery"
  value       = var.secondary_location
}

output "secondary_recovery_vault_id" {
  description = "The ID of the Recovery Services Vault in the secondary region"
  value       = azurerm_recovery_services_vault.rsv_secondary.id
}

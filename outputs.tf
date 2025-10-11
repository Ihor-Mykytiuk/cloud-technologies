output "core_services_vnet_id" {
  description = "The ID of the CoreServicesVnet"
  value       = azurerm_virtual_network.core_vnet.id
}

output "core_services_vm_id" {
  description = "The ID of the CoreServicesVM"
  value       = azurerm_windows_virtual_machine.core_vm.id
}

output "core_services_vm_private_ip" {
  description = "The private IP address of the CoreServicesVM"
  value       = azurerm_network_interface.core_vm_ni.private_ip_address
}

output "manufacturing_vnet_id" {
  description = "The ID of the ManufacturingVnet"
  value       = azurerm_virtual_network.mfg_vnet.id
}

output "manufacturing_vm_id" {
  description = "The ID of the ManufacturingVM"
  value       = azurerm_windows_virtual_machine.mfg_vm.id
}

output "manufacturing_vm_private_ip" {
  description = "The private IP address of the ManufacturingVM"
  value       = azurerm_network_interface.mfg_vm_ni.private_ip_address
}
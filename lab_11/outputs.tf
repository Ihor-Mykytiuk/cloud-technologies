output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "virtual_machine_name" {
  description = "The name of the created virtual machine"
  value       = azurerm_windows_virtual_machine.vm.name
}

output "virtual_machine_public_ip" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_public_ip.pip.ip_address
}
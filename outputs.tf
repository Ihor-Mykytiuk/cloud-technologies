output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "virtual_machine_ids" {
  description = "The resource IDs of the created virtual machines"
  value = {
    vm0 = azurerm_windows_virtual_machine.vm0.id
    vm1 = azurerm_windows_virtual_machine.vm1.id
    vm2 = azurerm_windows_virtual_machine.vm2.id
  }
}

output "virtual_machine_private_ips" {
  description = "Private IP addresses of the virtual machines"
  value = {
    vm0 = azurerm_network_interface.nic0.private_ip_address
    vm1 = azurerm_network_interface.nic1.private_ip_address
    vm2 = azurerm_network_interface.nic2.private_ip_address
  }
}
output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

# output "virtual_machine_details" {
#   description = "Details of the created virtual machines"
#   value = {
#     vm1 = {
#       name       = azurerm_windows_virtual_machine.vm1.name
#       private_ip = azurerm_network_interface.nic1.private_ip_address
#       zone       = azurerm_windows_virtual_machine.vm1.zone
#     }
#     vm2 = {
#       name       = azurerm_windows_virtual_machine.vm2.name
#       private_ip = azurerm_network_interface.nic2.private_ip_address
#       zone       = azurerm_windows_virtual_machine.vm2.zone
#     }
#   }
# }

output "vmss_load_balancer_public_ip" {
  description = "Public IP address of the Load Balancer for the VMSS"
  value       = azurerm_public_ip.vmss_lb_pip.ip_address
}

output "vmss_id" {
  description = "The resource ID of the Virtual Machine Scale Set"
  value       = azurerm_windows_virtual_machine_scale_set.vmss.id
}

output "autoscale_setting_id" {
  description = "The resource ID of the autoscale setting for the VMSS"
  value       = azurerm_monitor_autoscale_setting.vmss_autoscale.id
}
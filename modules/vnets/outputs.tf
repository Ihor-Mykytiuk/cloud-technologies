output "vnet_id" {
  description = "The ID of the created virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "A map of subnet names to their IDs."
  value = {
    for key, subnet in azurerm_subnet.subnet : key => subnet.id
  }
}
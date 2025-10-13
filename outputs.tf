output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "The name of the created storage account"
  value       = azurerm_storage_account.storage.name
}

output "your_detected_public_ip" {
  description = "Your public IP address that has been added to the firewall rules"
  value       = chomp(data.http.my_public_ip.response_body)
}
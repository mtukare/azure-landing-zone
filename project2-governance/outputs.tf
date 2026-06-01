# ================================================================
# project2-multi-env/outputs.tf
#
# Prints resource details in the GitHub Actions log after apply.
# Useful for verifying the right environment was deployed.
# ================================================================

output "environment" {
  description = "Active environment name — confirms which workspace ran"
  value       = var.env
}

output "resource_group_name" {
  description = "Name of the deployed resource group in Azure"
  value       = azurerm_resource_group.main.name
}

output "vnet_address_space" {
  description = "CIDR range — confirms correct env got correct IP range"
  value       = azurerm_virtual_network.main.address_space
}

output "storage_account_name" {
  description = "Storage account name — needed for any blob operations"
  value       = azurerm_storage_account.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI for storing app secrets"
  value       = azurerm_key_vault.main.vault_uri
}

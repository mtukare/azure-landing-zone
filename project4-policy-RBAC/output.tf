output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "policy_set_id" {
  value = azurerm_policy_set_definition.governance.id
}



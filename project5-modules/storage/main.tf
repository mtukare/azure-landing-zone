resource "azurerm_storage_account" "main" {
    name = "st${var.environment}${random_string.storage_account_suffix.result}"
    resource_group_name = azurerm_resource_group.main.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = var.replication_type
  
}

resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  container_access_type = var.container_access_type
}
resource "azurerm_storage_account" "site" {
  name                     = "stportfolio030526" # must be globally unique
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = var.location
}

resource "azurerm_resource_group" "main" {
  name     = "rg-portfolio"
  location = var.location

}

resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.site.id
  index_document     = "index.html"
  error_404_document = "404.html"
}



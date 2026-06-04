resource "azurerm_resource_group" "CDN" {
  name     = "rg-cdn"
  location = var.location


}


module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.CDN.name
  location            = var.location
  vnet_address_space  = var.vnet_address_space

}

resource "azurerm_key_vault" "main" {
  name                = "kv-portfolio-${random_id.kv_suffix.hex}"
  location            = var.location
  resource_group_name = azurerm_resource_group.CDN.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"


}

resource "azurerm_storage_account" "main" {
  name                = "stlandingzone${random_id.sa_suffix.hex}"
  resource_group_name = azurerm_resource_group.CDN.name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "monitoring"
    project     = "monitoring"
  }
}

resource "azurerm_storage_account_static_website" "main" {
  storage_account_id = azurerm_storage_account.main.id

  index_document     = "index.html"
  error_404_document = "404.html"
}

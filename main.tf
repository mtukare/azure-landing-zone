module "networking" {
  source               = "./modules/networking"
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  vnet_address_space   = var.vnet_address_space
  environment          = var.env # Add this to match variable name
  address_space_subnet = var.address_space_subnet
}

resource "azurerm_resource_group" "main" {
  name     = "rg-portfolio-${var.env}"
  location = var.location

  tags = {
    environment = var.env
  }
}

resource "azurerm_key_vault" "main" {
  name                        = "kv-portfolio-${var.env}-${random_string.suffix.result}"
  resource_group_name         = azurerm_resource_group.main.name
  location                    = var.location
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  purge_protection_enabled    = false
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  special = false

}

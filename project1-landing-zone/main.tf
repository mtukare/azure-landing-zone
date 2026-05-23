resource "azurerm_resource_group" "landing_zone" {
  name     = "rg-landing-zone"
  location = var.location

  tags = {
    environment = var.environment
    project     = "landing-zone"
  }

}


module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.landing_zone.name
  location            = var.location
  vnet_address_space  = var.vnet_address_space

}

resource "azurerm_key_vault" "main" {
  name                = "kv-portfolio-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}



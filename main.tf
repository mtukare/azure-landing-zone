module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_address_space  = var.vnet_address_space
  environment         = var.env  # Add this to match variable name
}

resource "azurerm_resource_group" "main" {
  name     = "rg-portfolio-${var.env}"
  location = var.location
  
}

resource "azurerm_key_vault" "main" {
  name                = "kv-portfolio-${var.env}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

#Virtual network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = var.vnet_address_space  # Fixed: removed quotes
  location            = var.location
  resource_group_name = var.resource_group_name
}

# app subnet
resource "azurerm_subnet" "app" {
  name                 = "app-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.address_space_subnet["subnet1"]]

}

# db subnet
resource "azurerm_subnet" "db" {
  name                 = "db-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.address_space_subnet["subnet2"]]

}

#Network security group for  subnet
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
}
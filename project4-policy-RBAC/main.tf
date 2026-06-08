#Resource group and core infrastructure for governance landing zone with RBAC 
#and Azure Policy

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Production"
    Owner       = "CloudTeam"
    Application = "Governance"
    CostCenter  = "IT"
  }
}

#Management lock to prevent accidental deletion of governance resources

resource "azurerm_management_lock" "rg_lock" {
  name       = "cannot-delete"
  scope      = azurerm_resource_group.main.id
  lock_level = "CanNotDelete"

  notes = "Protect governance resources from accidental deletion"
}

#Networking resources for governance landing zone

resource "azurerm_virtual_network" "main" {
  name                = "vnet-governance"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = [
    var.vnet_address_space
  ]

  tags = {
    Environment = "Production"
  }
}

#Subnets for governance landing zone-Creates a network segment inside the VNet.

resource "azurerm_subnet" "main" {
  name                 = "subnet-governance"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    var.subnet_prefix
  ]
}

#NSG to control traffic flow in governance landing zone

resource "azurerm_network_security_group" "main" {
  name                = "nsg-governance"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

#NSG association to link NSG with subnet


resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}



#role assignments for RBAC

resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = var.reader_principal_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = var.contributor_principal_id
}


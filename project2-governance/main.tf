
# ── Resource Group ───────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
  # Result: rg-dev-p2, rg-staging-p2, rg-prod-p2
  # All three can exist simultaneously in Azure — no name collision
  #test trigger
}

# ── Virtual Network ──────────────────────────────────────────────
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
  # dev=10.0.0.0/16, staging=10.1.0.0/16, prod=10.2.0.0/16
  # Different ranges prevent IP conflicts if you ever peer the VNets
  tags = local.common_tags
}

# ── Subnet ───────────────────────────────────────────────────────
resource "azurerm_subnet" "main" {
  name                 = "snet-${local.name_prefix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_address_prefix]
}

# ── Network Security Group ───────────────────────────────────────
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags

  # Only allow SSH inbound — same rule across all envs
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# ── Storage Account ──────────────────────────────────────────────
# Name must be 3-24 chars, globally unique, lowercase alphanumeric only.
# We use substr to keep it under 24 chars.
resource "azurerm_storage_account" "main" {
  name = "st${substr(replace(local.name_prefix, "-", ""), 0, 20)}"
  # dev   → stdevp2XXXX
  # prod  → stprodp2XXXX
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  # dev=LRS (cheapest, single datacenter)
  # prod=GRS (geo-redundant, survives regional outage)
  tags = local.common_tags
  #test test test
}



resource "azurerm_key_vault" "main" {
  name                = "kv-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku
  # dev=standard, prod=premium (hardware-backed keys)

  # Allows the deploying SP to manage secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
    key_permissions    = ["Get", "List", "Create", "Delete", "Purge"]
  }

  tags = local.common_tags
}

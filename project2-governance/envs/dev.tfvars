# ================================================================
# project2-multi-env/envs/dev.tfvars
#
# Development environment — smallest + cheapest settings.
# Destroy this after testing to save cost.
# ================================================================

env      = "dev"
location = "eastus"

# Networking — unique CIDR per env to prevent IP collisions
vnet_address_space    = ["10.0.0.0/16"]
subnet_address_prefix = "10.0.1.0/24"

# Storage — LRS = single datacenter, cheapest option
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Key Vault — standard tier is fine for dev
key_vault_sku = "standard"

tags = {
  owner       = "mtukare"
  cost-center = "dev-experiments"
  auto-delete = "true" # reminder tag — useful for cost management
}

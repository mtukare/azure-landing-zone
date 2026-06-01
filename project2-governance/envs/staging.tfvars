# ================================================================
# project2-multi-env/envs/staging.tfvars
#
# Staging environment — mirrors prod settings but with LRS storage.
# Used to catch issues before they reach prod.
# ================================================================

env      = "staging"
location = "eastus"

# Networking — different CIDR from dev to prevent overlap
vnet_address_space    = ["10.1.0.0/16"]
subnet_address_prefix = "10.1.1.0/24"

# Storage — still LRS but same tier as prod
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Key Vault — standard (same as dev, upgrade to premium only in prod)
key_vault_sku = "standard"

tags = {
  owner       = "mtukare"
  cost-center = "staging"
  auto-delete = "false"
}

# ================================================================
# project2-multi-env/envs/prod.tfvars
#
# Production environment — geo-redundant, premium where it matters.
# Only deployed from the main branch.
# ================================================================

env      = "prod"
location = "eastus"

# Networking — unique CIDR, larger /8 range for future growth
vnet_address_space    = ["10.2.0.0/16"]
subnet_address_prefix = "10.2.1.0/24"

# Storage — GRS = geo-redundant, survives full regional outage
storage_account_tier     = "Standard"
storage_replication_type = "GRS"

# Key Vault — premium = HSM-backed keys (hardware security module)
key_vault_sku = "standard" # change to "premium" when ready (costs more)

tags = {
  owner       = "mtukare"
  cost-center = "production"
  auto-delete = "false"
}

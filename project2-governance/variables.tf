# ================================================================
# project2-multi-env/variables.tf
#
# Declares EVERY variable used in main.tf.
# Actual values come from envs/dev.tfvars, staging.tfvars, prod.tfvars
# at runtime — never hardcoded here.
# ================================================================

# ── Environment identity ─────────────────────────────────────────
variable "env" {
  description = "Environment name: dev, staging, or prod. Used in all resource names."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
    # This catches typos at plan time — before anything touches Azure
  }
}

variable "location" {
  description = "Azure region. Can differ per environment (e.g. prod in eastus, dev in westus for cost)."
  type        = string
  default     = "eastus"
}

# ── Networking ───────────────────────────────────────────────────
variable "vnet_address_space" {
  description = "CIDR block for the VNet. Each env MUST use a different range to avoid overlap."
  type        = list(string)
  # dev     = ["10.0.0.0/16"]
  # staging = ["10.1.0.0/16"]
  # prod    = ["10.2.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "CIDR for the default subnet inside the VNet."
  type        = string
}

# ── Storage ──────────────────────────────────────────────────────
variable "storage_account_tier" {
  description = "Storage performance tier. dev=Standard, prod=Standard (Premium costs more)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "storage_account_tier must be Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Replication strategy. dev=LRS (cheapest), prod=GRS (geo-redundant)."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.storage_replication_type)
    error_message = "Must be LRS, GRS, RAGRS, or ZRS."
  }
}

# ── Key Vault ────────────────────────────────────────────────────
variable "key_vault_sku" {
  description = "Key Vault pricing tier. dev=standard, prod=premium (HSM-backed keys)."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "key_vault_sku must be standard or premium."
  }
}

# ── Tags ─────────────────────────────────────────────────────────
variable "tags" {
  description = "Tags applied to every resource. Merged with resource-specific tags."
  type        = map(string)
  default     = {}
}

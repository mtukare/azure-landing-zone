terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.74.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
}

# ── Key Vault ────────────────────────────────────────────────────
data "azurerm_client_config" "current" {}
# Fetches the current SP's tenant_id and object_id for Key Vault access policy

# ✅ Random ID resource declared separately
resource "random_id" "kv_suffix" {
  byte_length = 4
}

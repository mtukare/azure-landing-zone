# ================================================================
# project2-multi-env/backend.tf
#
#
# WHY blank? So no storage account names or resource group names
# are hardcoded in your repo. All sensitive config lives in
# GitHub Secrets.
#
# Terraform workspaces automatically namespace the state key:
#   workspace=dev    → project2.tfstate/env:/dev/terraform.tfstate
#   workspace=staging→ project2.tfstate/env:/staging/terraform.tfstate
#   workspace=prod   → project2.tfstate/env:/prod/terraform.tfstate
#
# This means all 3 environments share one storage container but
# have completely isolated state files. No risk of cross-env apply.
# ================================================================

terraform {
  backend "azurerm" {
    # resource_group_name injected via -backend-config in CI
    # storage_account_name injected via -backend-config in CI
    # container_name injected via -backend-config in CI
    # key injected via -backend-config in CI
  }
}


#terraform {
# backend "azurerm" {
#  resource_group_name  = "rg-tfstate"
# storage_account_name = "sttfstate220526"
#container_name       = "tfstate"
#key                  = "landing-zone.tfstate"
#use_azuread_auth     = true
#}
#}

# ── Local values ─────────────────────────────────────────────────
# Computed once, used many times. Single source of truth for naming.
locals {
  # Every resource name includes the environment: rg-dev-p2, rg-prod-p2, etc.
  name_prefix = "${var.env}-p2"

  # Merged tags applied to every resource
  common_tags = merge(var.tags, {
    environment = var.env
    managed_by  = "terraform"
    workspace   = terraform.workspace # records which workspace created this
  })
}

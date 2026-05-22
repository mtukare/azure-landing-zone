terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate220526"
    container_name       = "tfstate"
    key                  = "landing-zone.tfstate"
  }
}
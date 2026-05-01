terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate300426"
    container_name       = "tfstate"
    key                  = "landing-zone.tfstate"
  }
}
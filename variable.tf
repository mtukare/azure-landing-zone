variable "resource_group_name" {
  description = "name of the resource group"
  type        = string
  default     = "rg-dev"
}

variable "location" {
  description = "location of the resource group"
  type        = string
  default     = "eastus"
}

variable "env" {
  description = "environment name"
  type        = string
  default     = "dev"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
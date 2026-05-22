variable "location" {
    description = "The Azure region where the resources will be created."
    type        = string
    default     = "eastus"
  
}


variable "environment" { 
    description = "The environment for which the resources will be created (e.g., dev, prod)."
    type        = string
    default     = "dev"
  
}


variable "vnet_address_space" {
  description = "address space for the vnet"
  type = list(string)
  default = [ "10.0.0.0/16" ]

}

variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
  type        = string
}

variable "address_space_subnet" {
    description = "address space for the subnet"
    type = map(string)
    default = {
        "subnet1" = "10.0.1.0/24"
        "subnet2" = "10.0.2.0/24"
    }
}
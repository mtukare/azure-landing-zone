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

variable "address_space_subnet" {
  description = "The address space for the subnet"
  type        = map(string)
  default = {
    "subnet1" = "10.0.1.0/24"
    "subnet2" = "10.0.2.0/24"
  }
}

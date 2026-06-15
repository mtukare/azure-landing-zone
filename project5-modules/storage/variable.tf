variable "environment" {
  description = "The environment for which the resources will be created (e.g., dev, prod)."
  type        = string
  default     = "dev"

    validation {
    condition = contains(["dev","staging","prod"], var.environment)
    error_message = "Environment must be dev, staging or prod"
  }

}


variable "vnet_address_space" {
  description = "address space for the vnet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "eastus"
}

variable "replication_type" {
  type        = string
  description = "Replication type (LRS, GRS, RAGRS)"
  validation {
    condition     = contains(["LRS","GRS","RAGRS"], var.replication_type)
    error_message = "replication_type must be LRS, GRS, or RAGRS."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
  type        = string
  default     = "rg-landing-zone"
}

variable "container_name" {
  description = "The name of the storage container."
  type        = string
  default     = "container-landing-zone"
}

variable "container_access_type" {
  description = "The access type for the storage container."
  type        = string
  default     = "private"
}
variable "location" {
  description = "Azure deployment region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rg-portfolio-governance"
}

variable "vnet_address_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_prefix" {
  type    = string
  default = "10.0.1.0/24"
}

variable "reader_principal_id" {
  description = "Azure AD Object ID for Reader"
  type        = string
}

variable "contributor_principal_id" {
  description = "Azure AD Object ID for Contributor"
  type        = string
}
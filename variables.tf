############################################################
# variables.tf
############################################################

variable "location" {
  description = "Azure US Gov region (e.g. usgovvirginia, usgovtexas)."
  type        = string
  default     = "usgovvirginia"
}

variable "name_prefix" {
  description = "Optional prefix for resource names. Leave blank to auto-generate."
  type        = string
  default     = ""
}

variable "enable_purge_protection" {
  description = "Enable purge protection on Key Vault (irreversible once enabled). Recommended true for production."
  type        = bool
  default     = false
}

variable "key_vault_name" {
  description = "Name of the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "data_factory_name" {
  description = "Name of the Azure Data Factory."
  type        = string
}

variable "identity_name" {
  description = "Name of the managed identity."
  type        = string
}

# Subscription ID to deploy into. Supply via -var 'subscription_id=...' or
# environment variable TF_VAR_subscription_id. No default is set to avoid
# accidentally targeting the wrong subscription.
variable "subscription_id" {
  description = "Subscription ID to deploy into."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be a valid GUID."
  }
}
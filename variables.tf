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

# Optional: Use if you want to explicitly control the subscription in provider block.
# variable "subscription_id" {
#   description = "Subscription ID to deploy into."
#   type        = string
# }
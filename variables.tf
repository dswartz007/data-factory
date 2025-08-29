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

# Subscription ID to deploy into. Provide via -var or TF_VAR_subscription_id in CI if you
# do not want to rely on a default. Not a secret, but can be omitted for flexibility.
# If you prefer not to hard-code, remove the default line below.
variable "subscription_id" {
  description = "Subscription ID to deploy into."
  type        = string
  # default     = "00000000-0000-0000-0000-000000000000"
  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be a valid GUID."
  }
}


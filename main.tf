############################################################
# main.tf
# Deploys in Azure US Government:
# - Resource Group
# - User Assigned Managed Identity (for Key Vault + Data Factory CMK)
# - Key Vault + Customer Managed Key (RSA key)
# - Azure Data Factory encrypted with the CMK
#
# Quick Start (Azure Cloud Shell - US Gov):
#   az account set --subscription "<SUB_ID>"
#   terraform init
#   terraform plan -out tfplan
#   terraform apply tfplan
#   terraform destroy
#
# For production:
# - Enable Key Vault purge protection (set variable enable_purge_protection = true)
# - Use RBAC instead of (or in addition to) access policies where possible
# - Add remote state backend (Azure Storage) instead of local state
############################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  environment = "usgovernment"
  # Optional: explicitly set subscription
  subscription_id = var.subscription_id
}

############################################################
# Data Sources
############################################################

data "azurerm_client_config" "current" {}

############################################################
# Locals
############################################################

locals {
  key_vault_name       = var.key_vault_name
  resource_group_name  = var.resource_group_name
  identity_name        = var.identity_name
  adf_name             = var.data_factory_name
  key_name             = "adf-cmk-az01"
}

############################################################
# Resource Group
############################################################

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

############################################################
# User Assigned Managed Identity
############################################################

resource "azurerm_user_assigned_identity" "adf_identity" {
  name                = local.identity_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

############################################################
# Key Vault
############################################################

resource "azurerm_key_vault" "kv" {
  name                        = local.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = var.enable_purge_protection
  enabled_for_disk_encryption = false

  # Access policy for current (Global Administrator) user
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Update",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]
  }

  # Access policy for Data Factory's User Assigned Identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.adf_identity.principal_id

    key_permissions = [
      "Get",
      "List",
      "WrapKey",
      "UnwrapKey"
    ]
  }

  tags = {
    environment = "demo"
    component   = "keyvault"
  }
}

############################################################
# Key Vault Key
############################################################

resource "azurerm_key_vault_key" "adf_kek" {
  name         = local.key_name
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "wrapKey",
    "unwrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P365D"
    notify_before_expiry = "P30D"
  }

  depends_on = [
    azurerm_key_vault.kv
  ]
}

############################################################
# Azure Data Factory (with CMK)
############################################################

resource "azurerm_data_factory" "adf" {
  name                = local.adf_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.adf_identity.id]
  }

  customer_managed_key_id = azurerm_key_vault_key.adf_kek.id

  tags = {
    environment = "demo"
    security    = "cmk"
  }

  depends_on = [
    azurerm_key_vault_key.adf_kek
  ]
}

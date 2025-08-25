############################################################
# outputs.tf
############################################################

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Name of the Resource Group."
}

output "key_vault_name" {
  value       = azurerm_key_vault.kv.name
  description = "Key Vault name."
}

output "key_id_versioned" {
  value       = azurerm_key_vault_key.adf_kek.id
  description = "Versioned Key ID used for CMK."
}

# Uncomment if you want a versionless key id (for rotation strategies)
# locals {
#   key_id_versionless = regexreplace(azurerm_key_vault_key.adf_kek.id, "/[0-9a-fA-F-]{32}$", "")
# }
# output "key_id_versionless" {
#   value       = local.key_id_versionless
#   description = "Versionless Key ID."
# }

output "data_factory_name" {
  value       = azurerm_data_factory.adf.name
  description = "Azure Data Factory name."
}

output "user_assigned_identity_client_id" {
  value       = azurerm_user_assigned_identity.adf_identity.client_id
  description = "Client ID of the User Assigned Managed Identity."
}

output "user_assigned_identity_principal_id" {
  value       = azurerm_user_assigned_identity.adf_identity.principal_id
  description = "Principal (Object) ID of the User Assigned Managed Identity."
}
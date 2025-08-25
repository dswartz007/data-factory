# adfv2

Terraform deployment for Azure Data Factory (ADF) in Azure US Government secured with a Customer Managed Key (CMK) stored in Azure Key Vault. A User Assigned Managed Identity (UAMI) is used so the identity exists before ADF creation, avoiding circular dependencies for encryption.

## Resources Provisioned
- Resource Group
- User Assigned Managed Identity (UAMI)
- Azure Key Vault
- Key Vault RSA Key (CMK)
- Azure Data Factory (encrypted using the CMK)

## Azure US Government Considerations
The provider is set with `environment = "usgovernment"`. Ensure your Cloud Shell (or local Azure CLI) context is set to the correct US Gov subscription:
```bash
az account set --subscription "<SUBSCRIPTION_ID>"
```

## Prerequisites
- Terraform >= 1.5.0
- Sufficient Azure AD / tenant permissions (Global Administrator or appropriate RBAC) to assign Key Vault access policies and create identities.
- Logged into Azure CLI (Cloud Shell already is).

## Quick Start
```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan
# When finished
terraform destroy
```

## Variables
| Variable | Description | Default |
|----------|-------------|---------|
| location | Azure US Gov region | usgovvirginia |
| name_prefix | Optional naming prefix | (auto-generated) |
| enable_purge_protection | Key Vault purge protection (irreversible once true) | false |

## Key Vault & Access Policies
This example uses explicit access policies. For newer patterns, consider using Azure RBAC for Key Vault (set `public_network_access_enabled`, `network_acls`, etc., as needed) and granting the UAMI the `Key Vault Crypto User` role via `az role assignment` or Terraform `azurerm_role_assignment`.

## Customer Managed Key (CMK)
ADF consumes the key referenced by its full key versioned ID. Rotating the key (new version) will require you to update ADF if you want it to use a newer version (re-apply with new key version). You can adopt a versionless strategy for some services; ADF currently uses a versioned key ID when set at creation.

## Remote State (Recommended for Teams)
Add a backend (e.g., Azure Storage) to avoid local state conflicts:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "<state-rg>"
    storage_account_name = "<state-storage>"
    container_name       = "tfstate"
    key                  = "adfv2.tfstate"
  }
}
```

## GitHub Actions Workflow
The provided workflow:
- Runs on pull requests to `main`
- Performs `terraform fmt -check`, `init`, `validate`, and a read-only `plan`
- Does not auto-apply (you can add an apply job gated by approvals)

## Security / Hardening Recommendations
1. Enable Key Vault purge protection (set `enable_purge_protection = true`).
2. Lock down Key Vault network access (Private Endpoints or selected networks).
3. Use role assignments over access policies where feasible.
4. Store Terraform state in a secured remote backend.
5. Consider adding Diagnostic Settings for Key Vault and ADF.
6. Add Azure Policy to enforce CMK usage for Data Factory if required by compliance.

## Destroying
If purge protection is enabled, keys and vault persist through soft-delete retention. You may need to purge manually after destroy (only if desired):
```bash
az keyvault purge --name <kvName> --location usgovvirginia
```

## License
MIT (see LICENSE file). Change if your organization requires another license.

## Contributing
Open a pull request with clear description. CI will show format / validation issues.

## Future Enhancements (Optional)
- Add Data Factory linked services & pipelines modules.
- Implement Key rotation automation (Azure Automation / Event Grid).
- Add private endpoints for Key Vault and Data Factory managed endpoints where applicable.

---
Feel free to request any enhancements (RBAC model, network lockdown, diagnostics, private endpoints).
# Unifi Network Application Controller Fleet on Azure

This repo contains automation to deploy a hub resource group with central observability and other resources, plus a fleet of spoke resource groups with Unifi Network Application Controller (NAC) deployed in each spoke.

The hub resource group should be deployed first. Spoke resource groups, each with a VM running NAC, can be deployed in any order and additively over time.

## GitHub Actions Workflows

The following GitHub Actions workflows are provided:

- [/.github/workflows/DeployInfra-Main.yaml](/.github/workflows/DeployInfra-Main.yaml) - Deploy the hub resource group and the central/shared resources.
- [/.github/workflows/DestroyInfra-Main.yaml](/.github/workflows/DestroyInfra-Main.yaml) - Destroys the hub resource group and the central/shared resources. Additionally, removes diagnostics settings and role-based access control (RBAC) permissions to avoid leaving orphaned resources behind that are not removed by a simple resource group delete.
- [/.github/workflows/DeployController.yaml](/.github/workflows/DeployController.yaml) - Deploys a spoke resource group with a VM running NAC. Adds all RBAC permissions, diagnostics settings, deploys the VM, and configures the VM to run NAC with a Let's Encrypt TLS certificate.
- [/.github/workflows/DestroyController.yaml](/.github/workflows/DestroyController.yaml) - Destroys a spoke resource group with a VM running NAC. Additionally, removes diagnostics settings and RBAC permissions to avoid leaving orphaned resources behind that are not removed by a simple resource group delete.

## Variables and Configuration

The GitHub Actions workflows use both GitHub Actions Secrets and GitHub Actions Variables, as well as JSON files in the repo to configure the deployment.

### GitHub Secrets

The following GitHub Secrets are required. You should configure them in Repository Settings > Security > Secrets and variables > Actions.

- `AZURE_CREDENTIALS`: the JSON output of `az ad sp create-for-rbac --name "[YOUR SERVICE PRINCIPAL NAME]" --role Owner --scopes /subscriptions/[YOUR SUBSCRIPTION ID] --sdk-auth`. This is used to authenticate to Azure. Substitute your service principal name for `[YOUR SERVICE PRINCIPAL NAME]` and your Azure subscription ID for `[YOUR SUBSCRIPTION ID]`.
- `AZURE_SP_AA_INFRA_PRINCIPAL_ID`: the principal ID of the service principal you created for `AZURE_CREDENTIALS`. This is used to grant the service principal access to the Key Vault so that it can read and write secrets in GitHub Actions workflow steps.
- `AZURE_SUBSCRIPTION_ID`: your Azure subscription ID. This is used widely to scope Azure CLI commands to your subscription.
- `AZURE_TENANT_ID`: your Azure tenant ID. This is used to deploy Key Vault and User Assigned Identities.




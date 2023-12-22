# Unifi Network Application Controller Fleet on Azure

This repo contains automation to deploy a hub resource group with central observability and other resources, plus a fleet of spoke resource groups with Unifi Network Application Controller (NAC) deployed in each spoke.

The hub resource group should be deployed first. Spoke resource groups, each with a VM running NAC, can be deployed in any order and additively over time.

## Scenario

The scenario realized by this repo is for a managed service provider (MSP) to deploy a fleet of NAC VMs for their clients. The MSP can deploy a hub resource group with central observability and other resources, and then deploy a spoke resource group with a VM running NAC for each client. The MSP can then manage the NAC VMs for their clients from the hub resource group.

## GitHub Actions Workflows

The following GitHub Actions workflows are provided:

- [/.github/workflows/DeployInfra-Main.yaml](/.github/workflows/DeployInfra-Main.yaml) - Deploy the hub resource group and the central/shared resources.
- [/.github/workflows/DestroyInfra-Main.yaml](/.github/workflows/DestroyInfra-Main.yaml) - Destroys the hub resource group and the central/shared resources. Additionally, removes diagnostics settings and role-based access control (RBAC) permissions to avoid leaving orphaned resources behind that are not removed by a simple resource group delete.
- [/.github/workflows/DeployController.yaml](/.github/workflows/DeployController.yaml) - Deploys a spoke resource group with a VM running NAC. Adds all RBAC permissions, diagnostics settings, deploys the VM, and configures the VM to run NAC with a Let's Encrypt TLS certificate.
- [/.github/workflows/DestroyController.yaml](/.github/workflows/DestroyController.yaml) - Destroys a spoke resource group with a VM running NAC. Additionally, removes diagnostics settings and RBAC permissions to avoid leaving orphaned resources behind that are not removed by a simple resource group delete.

## Variables and Configuration

The GitHub Actions workflows use both GitHub Actions Secrets and GitHub Actions Variables, as well as JSON files in the repo to configure the deployment.

### GitHub Secrets

The following GitHub Secrets are required. You should configure them in Repository Settings > Security > Secrets and variables > Actions > Secrets.

- `AZURE_CREDENTIALS`: the JSON output of `az ad sp create-for-rbac --name "[YOUR SERVICE PRINCIPAL NAME]" --role Owner --scopes /subscriptions/[YOUR SUBSCRIPTION ID] --sdk-auth`. This is used to authenticate to Azure. Substitute your service principal name for `[YOUR SERVICE PRINCIPAL NAME]` and your Azure subscription ID for `[YOUR SUBSCRIPTION ID]`.
- `AZURE_SP_AA_INFRA_PRINCIPAL_ID`: the principal ID of the service principal you created for `AZURE_CREDENTIALS`. This is used to grant the service principal access to the Key Vault so that it can read and write secrets in GitHub Actions workflow steps.
- `AZURE_SUBSCRIPTION_ID`: your Azure subscription ID. This is used widely to scope Azure CLI commands to your subscription.
- `AZURE_TENANT_ID`: your Azure tenant ID. This is used to deploy Key Vault and User Assigned Identities.

### GitHub Variables

The following GitHub Variables are required. You should configure them in Repository Settings > Secrets and variables > Actions > Variables.

- `URL_ROOT_MODULE_PLZM_AZURE`: the URL to the Powershell module plzm.Azure, which contains many Powershell utility functions used by the pipelines and scripts in this repo. This Powershell module is maintained in the repo [plzm/azure-deploy](https://github.com/plzm/azure-deploy). By default, the pipelines and scripts in this repo will use the latest version of the module from the main branch.

### JSON Config Files

The following JSON config files are required for pipelines and scripts. Hard-coding of explicit strings in the pipelines and scripts is avoided by using config files and the instantiated $Config* objects used throughout the pipelines.

- [/config/infra_constants.json](/config/infra_constants.json) - various constant values set in one place, and used across pipelines and scripts, to avoid duplication of hard-coded strings.
- [/config/infra_controller_ssh.json](/config/infra_controller_ssh.json) - values used only for managing NAC VM SSH access during pipeline execution.
- [/config/infra_controller.json](/config/infra_controller.json) - values used for NAC VM deployment. This will be replaced by a more flexible store, such as a CRM database or similar, to avoid storing client information in a public repo and to enable more flexible deployment scenarios.
- [/config/infra_main.json](/config/infra_main.json) - values used for shared/hub resource deployments.

These files can be modified as needed. Key names should be maintained (or refactored throughout all pipelines and scripts).

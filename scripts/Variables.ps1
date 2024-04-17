function Set-VariablesMain()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigConstants,
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigMain,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId
  )

  # GitHub-hosted runner public IP address
  $runnerIp = plzm.Azure\Get-MyCurrentPublicIpAddress
  plzm.Azure\Set-EnvVar2 -VarName "AX_GITHUB_RUNNER_PUBLIC_IP" -VarValue "$runnerIp"

  # Resource Groups
  $rgNameMain = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixRsg -Suffix $ConfigMain.Suffix

  plzm.Azure\Set-EnvVar2 -VarName "AX_RG_NAME_MAIN" -VarValue "$rgNameMain"

  # Action Group
  $actionGroupName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixActionGroup -Sequence $ConfigMain.Suffix
  $actionGroupResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Insights" -ResourceTypeName "actionGroups" -ResourceName $actionGroupName

  plzm.Azure\Set-EnvVar2 -VarName "AX_ACG_NAME_MAIN" -VarValue "$actionGroupName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_ACG_RESOURCE_ID_MAIN" -VarValue "$actionGroupResourceId"

  # User Assigned Identity
  $uaiNameMain = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixUai -Suffix $ConfigMain.Suffix
  $uaiResourceIdMain = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.ManagedIdentity" -ResourceTypeName "userAssignedIdentities" -ResourceName $uaiNameMain

  plzm.Azure\Set-EnvVar2 -VarName "AX_UAI_NAME_MAIN" -VarValue "$uaiNameMain"
  plzm.Azure\Set-EnvVar2 -VarName "AX_UAI_RESOURCE_ID_MAIN" -VarValue "$uaiResourceIdMain"
  # In separate step after UAI provisioned
  # AX_UAI_CLIENT_ID_MAIN, AX_UAI_PRINCIPAL_ID_MAIN

  # Network
  $nsgName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixNsg -Suffix $ConfigMain.Suffix
  $nsgResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Network" -ResourceTypeName "networkSecurityGroups" -ResourceName $nsgName
  plzm.Azure\Set-EnvVar2 -VarName "AX_NSG_NAME" -VarValue "$nsgName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_NSG_RESOURCE_ID" -VarValue "$nsgResourceId"

  $vnetName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixVNet -Suffix $ConfigMain.Suffix
  $vnetResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Network" -ResourceTypeName "virtualNetworks" -ResourceName $vnetName
  plzm.Azure\Set-EnvVar2 -VarName "AX_VNET_NAME" -VarValue "$vnetName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_VNET_RESOURCE_ID" -VarValue "$vnetResourceId"

  Write-Debug -Debug:$true -Message "Get first subnet resource id for private endpoints"
  $subnetResourceIdForPrivateEndpoint = plzm.Azure\Get-NetworkSubnetResourceIdForPrivateEndpoint -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -VNetName $vnetName
  plzm.Azure\Set-EnvVar2 -VarName "AX_SUBNET_RESOURCE_ID_MAIN" -VarValue $subnetResourceIdForPrivateEndpoint


  # AMPLS
  $privateLinkScopeName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixAmpls -Sequence $ConfigConstants.SeqNumAmpls
  $privateLinkScopeResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "microsoft.insights" -ResourceTypeName "privatelinkscopes" -ResourceName $privateLinkScopeName

  plzm.Azure\Set-EnvVar2 -VarName "AX_AMPLS_NAME_MAIN" -VarValue "$privateLinkScopeName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_AMPLS_RESOURCE_ID_MAIN" -VarValue "$privateLinkScopeResourceId"

  # Log Analytics
  $workspaceName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixLogAnalytics -Sequence $ConfigConstants.SeqNumLogAnalytics
  $workspaceResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "microsoft.operationalinsights" -ResourceTypeName "workspaces" -ResourceName $workspaceName

  plzm.Azure\Set-EnvVar2 -VarName "AX_LAW_NAME_MAIN" -VarValue "$workspaceName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_LAW_RESOURCE_ID_MAIN" -VarValue "$workspaceResourceId"

  # Data Collection Endpoint and Rule
  $dataCollectionEndpointName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixDataCollectionEndpoint -Sequence $ConfigConstants.SeqNumDataCollectionEndpoint
  $dataCollectionEndpointResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Insights" -ResourceTypeName "dataCollectionEndpoints" -ResourceName $dataCollectionEndpointName

  $dataCollectionRuleName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixDataCollectionRule -Suffix $ConfigConstants.SuffixAmplsDataCollectionRuleLinux
  $dataCollectionRuleResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Insights" -ResourceTypeName "dataCollectionRules" -ResourceName $dataCollectionRuleName

  plzm.Azure\Set-EnvVar2 -VarName "AX_DCE_NAME" -VarValue "$dataCollectionEndpointName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_DCE_RESOURCE_ID" -VarValue "$dataCollectionEndpointResourceId"

  plzm.Azure\Set-EnvVar2 -VarName "AX_DCR_NAME" -VarValue "$dataCollectionRuleName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_DCR_RESOURCE_ID" -VarValue "$dataCollectionRuleResourceId"


  # Key Vault
  $keyVaultName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixKeyVault -Sequence $ConfigConstants.SeqNumKeyVault
  $keyVaultResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.KeyVault" -ResourceTypeName "vaults" -ResourceName $keyVaultName

  plzm.Azure\Set-EnvVar2 -VarName "AX_KEYVAULT_NAME_MAIN" -VarValue "$keyVaultName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_KEYVAULT_RESOURCE_ID_MAIN" -VarValue "$keyVaultResourceId"

  # Storage
  $storageAccountName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixStorageAccount -Sequence $ConfigConstants.SeqNumStorage -IncludeDelimiter $false
  $storageAccountResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Storage" -ResourceTypeName "storageAccounts" -ResourceName $storageAccountName

  plzm.Azure\Set-EnvVar2 -VarName "AX_STORAGE_ACCOUNT_NAME_MAIN" -VarValue "$storageAccountName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_STORAGE_ACCOUNT_RESOURCE_ID_MAIN" -VarValue "$storageAccountResourceId"

  # Env vars listed here for convenience
  # AX_GITHUB_RUNNER_PUBLIC_IP
  # AX_RG_NAME_MAIN
  # AX_ACG_NAME_MAIN
  # AX_ACG_RESOURCE_ID_MAIN
  # AX_UAI_NAME_MAIN
  # AX_UAI_RESOURCE_ID_MAIN
  # AX_UAI_CLIENT_ID_MAIN - set later
  # AX_UAI_PRINCIPAL_ID_MAIN - set later
  # AX_AMPLS_NAME_MAIN
  # AX_AMPLS_RESOURCE_ID_MAIN
  # AX_LAW_NAME_MAIN
  # AX_LAW_RESOURCE_ID_MAIN
  # AX_DCE_NAME
  # AX_DCE_RESOURCE_ID
  # AX_DCR_NAME
  # AX_DCR_RESOURCE_ID
  # AX_NSG_NAME
  # AX_NSG_RESOURCE_ID
  # AX_VNET_NAME
  # AX_VNET_RESOURCE_ID
  # AX_SUBNET_RESOURCE_ID_MAIN
  # AX_KEYVAULT_NAME_MAIN
  # AX_KEYVAULT_RESOURCE_ID_MAIN
  # AX_STORAGE_ACCOUNT_NAME_MAIN
  # AX_STORAGE_ACCOUNT_RESOURCE_ID_MAIN

}

function Set-VariablesController()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigConstants,
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigMain,
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigController,
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigControllerSsh,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId
  )
  # Resource Groups
  $rgNameController = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixRsg -Sequence $ConfigController.IdForNaming
  plzm.Azure\Set-EnvVar2 -VarName "AX_RG_NAME_CONTROLLER" -VarValue "$rgNameController"

  # User Assigned Identity
  $uaiNameController = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixUai -Sequence $ConfigController.IdForNaming
  $uaiResourceIdController = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameController" -ResourceProviderName "Microsoft.ManagedIdentity" -ResourceTypeName "userAssignedIdentities" -ResourceName $uaiNameController

  plzm.Azure\Set-EnvVar2 -VarName "AX_UAI_NAME_CONTROLLER" -VarValue "$uaiNameController"
  plzm.Azure\Set-EnvVar2 -VarName "AX_UAI_RESOURCE_ID_CONTROLLER" -VarValue "$uaiResourceIdController"
  # In separate step after UAI provisioned
  # AX_UAI_CLIENT_ID_CONTROLLER, AX_UAI_PRINCIPAL_ID_CONTROLLER

  # SSH for Controller VM
  $sshKeyName = $ConfigConstants.SshKeyNamePrefix + $ConfigController.IdForNaming
  plzm.Azure\Set-EnvVar2 -VarName "AX_SSH_KEY_NAME_CONTROLLER" -VarValue "$sshKeyName"

  # Controller VM
  $vmName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixVirtualMachine -Sequence $ConfigController.IdForNaming
  $vmResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameController" -ResourceProviderName "Microsoft.Compute" -ResourceTypeName "virtualMachines" -ResourceName $vmName

  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_NAME_CONTROLLER" -VarValue "$vmName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_RESOURCE_ID_CONTROLLER" -VarValue "$vmResourceId"

  $hostName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Sequence $ConfigController.IdForNaming
  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_HOSTNAME_CONTROLLER" -VarValue "$hostName"

  $vmPipName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixPublicIpAddress -Sequence $ConfigController.IdForNaming
  $vmPipResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameController" -ResourceProviderName "Microsoft.Network" -ResourceTypeName "publicIPAddresses" -ResourceName $vmPipName

  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_PIP_NAME_CONTROLLER" -VarValue "$vmPipName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_PIP_RESOURCE_ID_CONTROLLER" -VarValue "$vmPipResourceId"

  $vmNicName = plzm.Azure\Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixNic -Sequence $ConfigController.IdForNaming
  $vmNicResourceId = plzm.Azure\Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameController" -ResourceProviderName "Microsoft.Network" -ResourceTypeName "networkInterfaces" -ResourceName $vmNicName

  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_NIC_NAME_CONTROLLER" -VarValue "$vmNicName"
  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_NIC_RESOURCE_ID_CONTROLLER" -VarValue "$vmNicResourceId"

  # Controller VM SSH
  $vmAdminUsername = $ConfigController.Vm.AdminUserName
  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_ADMIN_USERNAME" -VarValue "$vmAdminUsername"

  $sshPath = $ConfigConstants.SshPath
  plzm.Azure\Set-EnvVar2 -VarName "AX_VM_SSH_PATH" -VarValue "$sshPath"

  # Env vars listed here for convenience
  # AX_RG_NAME_CONTROLLER
  # AX_UAI_NAME_CONTROLLER
  # AX_UAI_RESOURCE_ID_CONTROLLER
  # AX_UAI_CLIENT_ID_CONTROLLER - set later
  # AX_UAI_PRINCIPAL_ID_CONTROLLER - set later
  # AX_SSH_KEY_NAME_CONTROLLER
  # AX_VM_NAME_CONTROLLER
  # AX_VM_RESOURCE_ID_CONTROLLER
  # AX_VM_HOSTNAME_CONTROLLER
  # AX_VM_PIP_NAME_CONTROLLER
  # AX_VM_PIP_RESOURCE_ID_CONTROLLER
  # AX_VM_NIC_NAME_CONTROLLER
  # AX_VM_NIC_RESOURCE_ID_CONTROLLER
  # AX_VM_ADMIN_USERNAME
  # AX_VM_SSH_PATH
}

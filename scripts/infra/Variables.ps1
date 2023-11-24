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

  # Tags
  Set-EnvVarTags -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain

  # Resource Groups
  $rgNameMain = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixRsg -Suffix $ConfigMain.Suffix

  Set-EnvVar2 -VarName "AA_RG_NAME_MAIN" -VarValue "$rgNameMain"

  # User Assigned Identity
  $uaiNameMain = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixUai -Suffix $ConfigMain.Suffix
  $uaiResourceIdMain = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.ManagedIdentity" -ResourceTypeName "userAssignedIdentities" -ResourceName $uaiNameMain

  Set-EnvVar2 -VarName "AA_UAI_NAME_MAIN" -VarValue "$uaiNameMain"
  Set-EnvVar2 -VarName "AA_UAI_RESOURCE_ID_MAIN" -VarValue "$uaiResourceIdMain"
  # In separate step after UAI provisioned
  # AA_UAI_CLIENT_ID_MAIN, AA_UAI_PRINCIPAL_ID_MAIN

  # Network
  $nsgName = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixNsg -Suffix $ConfigMain.Suffix
  $nsgResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Network" -ResourceTypeName "networkSecurityGroups" -ResourceName $nsgName
  Set-EnvVar2 -VarName "AA_NSG_NAME" -VarValue "$nsgName"
  Set-EnvVar2 -VarName "AA_NSG_RESOURCE_ID" -VarValue "$nsgResourceId"

  $vnetName = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixVNet -Suffix $ConfigMain.Suffix
  $vnetResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Network" -ResourceTypeName "virtualNetworks" -ResourceName $vnetName
  Set-EnvVar2 -VarName "AA_VNET_NAME" -VarValue "$vnetName"
  Set-EnvVar2 -VarName "AA_VNET_RESOURCE_ID" -VarValue "$vnetResourceId"

  Write-Debug -Debug:$true -Message "Get first subnet resource id for private endpoints"
  $subnetResourceIdForPrivateEndpoint = Get-SubnetResourceIdForPrivateEndpoint -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -VNetName $vnetName
  Set-EnvVar2 -VarName "AA_SUBNET_RESOURCE_ID_PRIVATE_ENDPOINT" -VarValue $subnetResourceIdForPrivateEndpoint


  # AMPLS
  $privateLinkScopeName = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixAmpls -Sequence $ConfigConstants.SeqNumAmpls
  $privateLinkScopeResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "microsoft.insights" -ResourceTypeName "privatelinkscopes" -ResourceName $privateLinkScopeName

  Set-EnvVar2 -VarName "AA_AMPLS_NAME_MAIN" -VarValue "$privateLinkScopeName"
  Set-EnvVar2 -VarName "AA_AMPLS_RESOURCE_ID_MAIN" -VarValue "$privateLinkScopeResourceId"

  # Log Analytics
  $workspaceName = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixLogAnalytics -Sequence $ConfigConstants.SeqNumberLogAnalytics
  $workspaceResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "microsoft.operationalinsights" -ResourceTypeName "workspaces" -ResourceName $workspaceName

  Set-EnvVar2 -VarName "AA_LAW_NAME_MAIN" -VarValue "$workspaceName"
  Set-EnvVar2 -VarName "AA_LAW_RESOURCE_ID_MAIN" -VarValue "$workspaceResourceId"

  # Key Vault
  $keyVaultName = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixKeyVault -Sequence $ConfigConstants.SeqNumKeyVault
  $keyVaultResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.KeyVault" -ResourceTypeName "vaults" -ResourceName $keyVaultName

  Set-EnvVar2 -VarName "AA_KEYVAULT_NAME_MAIN" -VarValue "$keyVaultName"
  Set-EnvVar2 -VarName "AA_KEYVAULT_RESOURCE_ID_MAIN" -VarValue "$keyVaultResourceId"

  # Storage
  $storageAccountName = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixStorageAccount -Sequence $ConfigConstants.SeqNumStorage -IncludeDelimiter $false
  $storageAccountResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameMain" -ResourceProviderName "Microsoft.Storage" -ResourceTypeName "storageAccounts" -ResourceName $storageAccountName

  Set-EnvVar2 -VarName "AA_STORAGE_ACCOUNT_NAME_MAIN" -VarValue "$storageAccountName"
  Set-EnvVar2 -VarName "AA_STORAGE_ACCOUNT_RESOURCE_ID_MAIN" -VarValue "$storageAccountResourceId"

  # Env vars listed here for convenience
  # AA_TAGS_FOR_CLI
  # AA_TAGS_FOR_ARM
  # AA_RG_NAME_MAIN
  # AA_UAI_NAME_MAIN
  # AA_UAI_RESOURCE_ID_MAIN
  # AA_UAI_CLIENT_ID_MAIN - set below
  # AA_UAI_PRINCIPAL_ID_MAIN - set below
  # AA_AMPLS_NAME_MAIN
  # AA_AMPLS_RESOURCE_ID_MAIN
  # AA_LAW_NAME_MAIN
  # AA_LAW_RESOURCE_ID_MAIN
  # AA_NSG_NAME
  # AA_NSG_RESOURCE_ID
  # AA_VNET_NAME
  # AA_VNET_RESOURCE_ID
  # AA_SUBNET_RESOURCE_ID_PRIVATE_ENDPOINT
  # AA_KEYVAULT_NAME_MAIN
  # AA_KEYVAULT_RESOURCE_ID_MAIN
  # AA_STORAGE_ACCOUNT_NAME_MAIN
  # AA_STORAGE_ACCOUNT_RESOURCE_ID_MAIN

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
    [string]
    $SubscriptionId
  )
  # Resource Groups
  $rgNameController = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixRsg -Sequence $ConfigController.IdForNaming
  Set-EnvVar2 -VarName "AA_RG_NAME_CONTROLLER" -VarValue "$rgNameController"


  # User Assigned Identity
  $uaiNameController = Get-ResourceName -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -Prefix $ConfigConstants.PrefixUai -Sequence $ConfigController.IdForNaming
  $uaiResourceIdController = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName "$rgNameController" -ResourceProviderName "Microsoft.ManagedIdentity" -ResourceTypeName "userAssignedIdentities" -ResourceName $uaiNameController

  Set-EnvVar2 -VarName "AA_UAI_NAME_CONTROLLER" -VarValue "$uaiNameController"
  Set-EnvVar2 -VarName "AA_UAI_RESOURCE_ID_CONTROLLER" -VarValue "$uaiResourceIdController"
  # In separate step after UAI provisioned
  # AA_UAI_CLIENT_ID_CONTROLLER, AA_UAI_PRINCIPAL_ID_CONTROLLER


}
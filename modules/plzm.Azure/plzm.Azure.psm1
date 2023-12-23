# ##################################################
# AzureAccount.ps1
# ##################################################

function Get-AzureRegions()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false)]
    [string[]]
    $FilterDisplayNames = $null,
    [Parameter(Mandatory = $false)]
    [string[]]
    $FilterShortNames = $null
  )

  Write-Debug -Debug:$true -Message "Get Azure Regions"

  $locations = Get-AzLocation

  if ($FilterDisplayNames)
  {
    $locations = $locations | Where-Object {$_.DisplayName -in $FilterDisplayNames}
  }
  elseif ($FilterShortNames)
  {
    $locations = $locations | Where-Object {$_.Location -in $FilterShortNames}
  }

  return $locations
}

# ##################################################
# AzureAppService.ps1
# ##################################################

function Deploy-AppInsights()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppInsightsName,
    [Parameter(Mandatory = $true)]
    [string]
    $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory = $false)]
    [string]
    $LinkedStorageAccountResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccessForIngestion = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccessForQuery = "Enabled",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy App Insights $AppInsightsName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppInsightsName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appInsightsName="$AppInsightsName" `
    logAnalyticsWorkspaceResourceId="$LogAnalyticsWorkspaceResourceId" `
    linkedStorageAccountResourceId="$LinkedStorageAccountResourceId" `
    publicNetworkAccessForIngestion="$PublicNetworkAccessForIngestion" `
    publicNetworkAccessForQuery="$PublicNetworkAccessForQuery" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppServiceCertificate()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServicePlanResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServiceCertificateName,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultSecretName,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy App Service Certificate $AppServiceCertificateName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppServiceCertificateName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appServicePlanResourceId="$AppServicePlanResourceId" `
    certificateName="$AppServiceCertificateName" `
    keyVaultResourceId="$KeyVaultResourceId" `
    keyVaultSecretName="$KeyVaultSecretName" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppService()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServiceName,
    [Parameter(Mandatory = $true)]
    [string]
    $Kind,
    [Parameter(Mandatory = $false)]
    [bool]
    $AssignSystemIdentity = $false,
    [Parameter(Mandatory = $false)]
    [string]
    $UserAssignedIdentityResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $UserAssignedIdentityClientId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $AppServicePlanResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $AppInsightsResourceId = "",
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $false)]
    [string]
    $FunctionRuntimeVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $FunctionRuntimeWorker = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Language = "",
    [Parameter(Mandatory = $false)]
    [string]
    $LinuxFxVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DotnetVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PythonVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccess = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $SubnetResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $RouteAllTrafficThroughVNet = $true,
    [Parameter(Mandatory = $false)]
    [string]
    $AllowedIpAddressRanges = "",
    [Parameter(Mandatory = $false)]
    [string]
    $CustomFqdn = "",
    [Parameter(Mandatory = $false)]
    [string]
    $CertificateForAppServiceThumbprint = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy App Service $AppServiceName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppServiceName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appServiceName="$AppServiceName" `
    kind="$Kind" `
    assignSystemIdentity="$AssignSystemIdentity" `
    userAssignedIdentityResourceId="$UserAssignedIdentityResourceId" `
    userAssignedIdentityClientId="$UserAssignedIdentityClientId" `
    appServicePlanResourceId="$AppServicePlanResourceId" `
    appInsightsResourceId="$AppInsightsResourceId" `
    storageAccountResourceId="$StorageAccountResourceId" `
    storageAccountName="$StorageAccountName" `
    functionRuntimeVersion="$FunctionRuntimeVersion" `
    functionRuntimeWorker="$FunctionRuntimeWorker" `
    language="$Language" `
    linuxFxVersion="$LinuxFxVersion" `
    dotnetVersion="$DotnetVersion" `
    pythonVersion="$PythonVersion" `
    publicNetworkAccess="$PublicNetworkAccess" `
    subnetResourceId="$SubnetResourceId" `
    routeAllTrafficThroughVNet="$RouteAllTrafficThroughVNet" `
    allowedIpAddressRanges="$AllowedIpAddressRanges" `
    customFqdn="$CustomFqdn" `
    certificateForAppServiceThumbprint="$CertificateForAppServiceThumbprint" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppServicePlan()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServicePlanName,
    [Parameter(Mandatory = $true)]
    [string]
    $SkuName,
    [Parameter(Mandatory = $true)]
    [string]
    $SkuTier,
    [Parameter(Mandatory = $true)]
    [string]
    $SkuFamily,
    [Parameter(Mandatory = $true)]
    [string]
    $Capacity,
    [Parameter(Mandatory = $true)]
    [string]
    $Kind,
    [Parameter(Mandatory = $false)]
    [bool]
    $ZoneRedundant = $true,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy App Service Plan $AppServicePlanName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppServicePlanName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appServicePlanName="$AppServicePlanName" `
    skuName="$SkuName" `
    skuTier="$SkuTier" `
    skuFamily="$SkuFamily" `
    capacity="$Capacity" `
    kind="$Kind" `
    zoneRedundant="$ZoneRedundant" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppServicePlanAutoscaleSettings()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AutoscaleSettingsName,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServicePlanResourceId,
    [Parameter(Mandatory = $true)]
    [int]
    $MinimumInstances,
    [Parameter(Mandatory = $true)]
    [int]
    $MaximumInstances,
    [Parameter(Mandatory = $true)]
    [int]
    $DefaultInstances,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy App Service Plan Autoscale Settings $AutoscaleSettingsName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AutoscaleSettingsName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    autoScaleSettingsName="$AutoscaleSettingsName" `
    appServicePlanResourceId="$AppServicePlanResourceId" `
    minimumInstances="$MinimumInstances" `
    maximumInstances="$MaximumInstances" `
    defaultInstances="$DefaultInstances" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}


# ##################################################
# AzureContainerRegistry.ps1
# ##################################################

function New-AzureContainerRegistryImage()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $RegistryName,
    [Parameter(Mandatory=$true)]
    [string]
    $ImageName,
    [Parameter(Mandatory=$true)]
    [string]
    $Version
  )
  Write-Debug -Debug:$true -Message "New-AzureContainerRegistryImage $ImageName/$Version"

  $registry = $RegistryName.ToLowerInvariant()
  $baseImage = $registry + ".azurecr.io/" + $ImageName
  $versionedImage = $baseImage + ":" + $Version
  $latestImage = $baseImage + ":latest"

  $dockerBuildCmd = "docker build -f Dockerfile -t $versionedImage -t $latestImage ."
  Write-Debug -Debug:$true -Message "dockerBuildCmd: $dockerBuildCmd"
  Invoke-Expression $dockerBuildCmd

  $dockerPushCmd = "docker image push --all-tags $baseImage"
  Write-Debug -Debug:$true -Message "dockerPushCmd: $dockerPushCmd"
  Invoke-Expression $dockerPushCmd
}

function Set-AzureContainerRegistryAdminUserEnabled()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $RegistryName,
    [Parameter(Mandatory=$true)]
    [bool]
    $AdminUserEnabled
  )
  Write-Debug -Debug:$true -Message "Set-AzureContainerRegistryAdminUserEnabled $RegistryName/$AdminUserEnabled"

  $output = az acr update `
    -g $ResourceGroupName `
    -n $RegistryName `
    --admin-enabled $AdminUserEnabled `
    | ConvertFrom-Json

  Write-Debug -Debug:$true -Message $output
}

function Set-AzureContainerRegistryImageToAppService()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $AppServiceName,
    [Parameter(Mandatory=$true)]
    [string]
    $RegistryName,
    [Parameter(Mandatory=$true)]
    [string]
    $ImageName,
    [Parameter(Mandatory=$false)]
    [string]
    $Version = "latest"
  )
  Write-Debug -Debug:$true -Message "Set-AzureContainerRegistryImageToAppService $RegistryName/$ImageName/$Version"

  $acrFqdn = "$RegistryName.azurecr.io"
  $acrUrl = "https://$acrFqdn"
  $image = "$acrFqdn" + "/" + "$ImageName" + ":" + "$Version"

  az webapp config container set `
    -g $ResourceGroupName `
    -n $AppServiceName `
    --docker-registry-server-url $acrUrl `
    --docker-custom-image-name $image
}

function Set-AzureContainerRegistryPublicNetworkAccess()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $RegistryName,
    [Parameter(Mandatory=$true)]
    [bool]
    $PublicNetworkEnabled,
    [Parameter(Mandatory=$false)]
    [string]
    $DefaultAction = "Deny"
  )
  Write-Debug -Debug:$true -Message "Set-AzureContainerRegistryPublicNetworkAccess $RegistryName/$PublicNetworkEnabled"

  $output = az acr update `
    -g $ResourceGroupName `
    -n $RegistryName `
    --public-network-enabled $PublicNetworkEnabled `
    --default-action $DefaultAction `
    | ConvertFrom-Json

  Write-Debug -Debug:$true -Message $output
}

function Set-AzureContainerRegistryNetworkRule()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $RegistryName,
    [Parameter(Mandatory=$true)]
    [string]
    $IpAddressRange,
    [Parameter(Mandatory=$false)]
    [string]
    $Action = "Remove"
  )
  Write-Debug -Debug:$true -Message "Set-AzureContainerRegistryNetworkRule $RegistryName/$IpAddressRange/$Action"

  if ($Action.ToLowerInvariant() -eq "add")
  {
    $output = az acr network-rule add `
      -g $ResourceGroupName `
      -n $RegistryName `
      --ip-address $IpAddressRange `
      | ConvertFrom-Json
  }
  else
  {
    $output = az acr network-rule remove `
      -g $ResourceGroupName `
      -n $RegistryName `
      --ip-address $IpAddressRange `
      | ConvertFrom-Json
  }

  Write-Debug -Debug:$true -Message $output
}

# ##################################################
# AzureCosmosDB.ps1
# ##################################################

function New-CosmosDbFailoverPolicy()
{
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName
  )
  $DefinitionName = "audit-cosmosdb-autofailover-georeplication"
  $DefinitionDisplayName = "Audit Automatic Failover for CosmosDB accounts"
  $DefinitionDescription = "This policy audits Automatic Failover for CosmosDB accounts"
  $PolicyUrl = "https://raw.githubusercontent.com/Azure/azure-policy/master/samples/CosmosDB/audit-cosmosdb-autofailover-georeplication/azurepolicy.rules.json"
  $ParametersUrl = "https://raw.githubusercontent.com/Azure/azure-policy/master/samples/CosmosDB/audit-cosmosdb-autofailover-georeplication/azurepolicy.parameters.json"
  $AssignmentName = ($ResourceGroupName + "-" + $DefinitionName)

  $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

  $definition = New-AzPolicyDefinition -Name $DefinitionName -DisplayName $DefinitionDisplayName -description $DefinitionDescription -Policy $PolicyUrl -Parameter $ParametersUrl -Mode All
  $definition

  $assignment = New-AzPolicyAssignment -Name $AssignmentName -Scope $ResourceGroup.ResourceId -PolicyDefinition $definition
  $assignment
}


# ##################################################
# AzureDataFactory.ps1
# ##################################################

function Remove-DataFactoriesByAge()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [int]
    $DaysOlderThan
  )

  Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionName"
  az account set -s $SubscriptionName

  $query = "[].{Name: name, CreateTime: createTime}"
  $factories = $(az datafactory list -g $ResourceGroupName --query $query) | ConvertFrom-Json

  $daysBack = -1 * [Math]::Abs($DaysOlderThan) # Just in case someone passes a negative number to begin with
  $compareDate = (Get-Date).AddDays($daysBack)

  foreach ($factory in $factories)
  {
    $deleteThis = ($compareDate -gt [DateTime]$factory.CreateTime)

    if ($deleteThis)
    {
      Write-Debug -Debug:$true -Message ("Deleting factory " + $factory.Name)
      az datafactory delete -g $ResourceGroupName -n $factory.Name --yes
    }
    else
    {
      Write-Debug -Debug:$true -Message ("No Op on factory " + $factory.Name)
    }
  }
}


# ##################################################
# AzureFunctions.ps1
# ##################################################

function Get-FunctionIdentityPrincipalId()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $FunctionAppName
  )
  Write-Debug -Debug:$true -Message "Get function identity principal id for app $FunctionAppName"
  $principalId = "$(az functionapp identity show --name $FunctionAppName -g $ResourceGroupName -o tsv --query 'principalId')"

  return $principalId
}

function Set-FunctionKey()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $FunctionAppName,
    [Parameter(Mandatory=$true)]
    [string]
    $FunctionKeyName
  )
  Write-Debug -Debug:$true -Message "Set new Function key $FunctionKeyName on Function App $FunctionAppName and get its value on the output"
  $keyValue = "$(az functionapp keys set --key-name $FunctionKeyName --key-type functionKeys --name $FunctionAppName -g $ResourceGroupName -o tsv --query 'value')"

  return $keyValue
}


# ##################################################
# AzureKeyVault.ps1
# ##################################################

function Deploy-KeyVault()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $TenantId,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnabledForDeployment = $false,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnabledForDiskEncryption = $false,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnabledForTemplateDeployment = $false,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableSoftDelete = $false,
    [Parameter(Mandatory = $false)]
    [int]
    $SoftDeleteRetentionInDays = 7,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableRbacAuthorization = $true,
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccess = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $DefaultAction = "Deny",
    [Parameter(Mandatory = $false)]
    [string]
    $AllowedIpAddressRangesCsv = "",
    [Parameter(Mandatory = $false)]
    [string]
    $AllowedSubnetResourceIdsCsv = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Key Vault $KeyVaultName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$KeyVaultName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    tenantId="$TenantId" `
    keyVaultName="$KeyVaultName" `
    enabledForDeployment="$EnabledForDeployment" `
    enabledForDiskEncryption="$EnabledForDiskEncryption" `
    enabledForTemplateDeployment="$EnabledForTemplateDeployment" `
    enableSoftDelete="$EnableSoftDelete" `
    softDeleteRetentionInDays="$SoftDeleteRetentionInDays" `
    enableRbacAuthorization="$EnableRbacAuthorization" `
    publicNetworkAccess="$PublicNetworkAccess" `
    defaultAction="$DefaultAction" `
    allowedIpAddressRanges="$AllowedIpAddressRangesCsv" `
    allowedSubnetResourceIds="$AllowedSubnetResourceIdsCsv" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Get-KeyVaultSecret()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory=$true)]
    [string]
    $SecretName
  )
  Write-Debug -Debug:$true -Message "Get Key Vault $KeyVaultName Secret $SecretName"

  $secretValue = ""

  if ($SecretName)
  {
    $secretNameSafe = Get-KeyVaultSecretName -VarName "$SecretName"

    $secretValue = az keyvault secret show `
      --subscription "$SubscriptionId" `
      --vault-name "$KeyVaultName" `
      --name "$secretNameSafe" `
      -o tsv `
      --query 'value' 2>&1

    if (!$?)
    {
      $secretValue = ""
    }
  }

  return $secretValue
}

function Get-KeyVaultSecretName()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $VarName
  )
  # Fix KV secret name; only - and alphanumeric allowed
  $secretName = $VarName.Replace(":", "-").Replace("_", "-")

  return $secretName
}

function New-KeyVaultNetworkRuleForIpAddressOrRange()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory = $true)]
    [string]
    $IpAddressOrRange
  )

  Write-Debug -Debug:$true -Message "Add Key Vault $KeyVaultName Network Rule for $IpAddressOrRange"

  $output = az keyvault network-rule add `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    -n "$KeyVaultName" `
    --ip-address "$IpAddressOrRange" `
    | ConvertFrom-Json

  return $output
}

function New-KeyVaultNetworkRuleForVnetSubnet()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetName
  )

  Write-Debug -Debug:$true -Message "Add Key Vault $KeyVaultName Network Rule for $VNetName and $SubnetName"

  $output = az keyvault network-rule add `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    -n "$KeyVaultName" `
    --vnet-name "$VNetName" `
    --subnet "$SubnetName" `
    | ConvertFrom-Json

  return $output
}

function Remove-KeyVaultNetworkRuleForIpAddressOrRange()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory = $true)]
    [string]
    $IpAddressOrRange
  )

  Write-Debug -Debug:$true -Message "Remove Key Vault $KeyVaultName Network Rule for $IpAddressOrRange"

  $output = az keyvault network-rule remove `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    -n "$KeyVaultName" `
    --ip-address "$IpAddressOrRange" `
    | ConvertFrom-Json

  return $output
}

function Remove-KeyVaultNetworkRuleForVnetSubnet()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetName
  )

  Write-Debug -Debug:$true -Message "Remove Key Vault $KeyVaultName Network Rule for $VNetName and $SubnetName"

  $output = az keyvault network-rule remove `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    -n "$KeyVaultName" `
    --vnet-name "$VNetName" `
    --subnet "$SubnetName" `
    | ConvertFrom-Json

  return $output
}

function Remove-KeyVaultSecret()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory=$true)]
    [string]
    $SecretName
  )
  Write-Debug -Debug:$true -Message "Remove Key Vault $KeyVaultName Secret $SecretName"

  if ($SecretName)
  {
    $secretNameSafe = Get-KeyVaultSecretName -VarName "$SecretName"

    $output = az keyvault secret delete `
      --subscription "$SubscriptionId" `
      --vault-name "$KeyVaultName" `
      --name "$secretNameSafe" `
      | ConvertFrom-Json
  }

  return $output
}

function Set-KeyVaultNetworkSettings()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccess = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $DefaultAction = "Deny"
  )

  Write-Debug -Debug:$true -Message "Set Key Vault $KeyVaultName Network Settings: PublicNetworkAccess=$PublicNetworkAccess, DefaultAction=$DefaultAction"

  $output = az keyvault update `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    -n "$KeyVaultName" `
    --public-network-access "$PublicNetworkAccess" `
    --default-action "$DefaultAction" `
    --bypass AzureServices `
    | ConvertFrom-Json

  return $output
}

function Set-KeyVaultSecret()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory=$true)]
    [string]
    $SecretName,
    [Parameter(Mandatory=$true)]
    [string]
    $SecretValue
  )
  Write-Debug -Debug:$true -Message "Set Key Vault $KeyVaultName Secret $SecretName"

  $secretNameSafe = Get-KeyVaultSecretName -VarName "$SecretName"

  az keyvault secret set `
    --vault-name "$KeyVaultName" `
    --name "$secretNameSafe" `
    --value "$SecretValue" `
    --output none
}


# ##################################################
# AzureMonitor.ps1
# ##################################################

function Deploy-DiagnosticsSetting()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $DiagnosticsSettingName,
    [Parameter(Mandatory = $true)]
    [string]
    $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory = $false)]
    [bool]
    $SendLogs = $true,
    [Parameter(Mandatory = $false)]
    [bool]
    $SendMetrics = $true
  )

  Write-Debug -Debug:$true -Message "Deploy Diagnostics Setting $DiagnosticsSettingName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DiagnosticsSettingName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    resourceId="$ResourceId" `
    diagnosticsSettingName="$DiagnosticsSettingName" `
    logAnalyticsWorkspaceResourceId="$LogAnalyticsWorkspaceResourceId" `
    sendLogs=$SendLogs `
    sendMetrics=$SendMetrics `
    | ConvertFrom-Json

  return $output
}

function Deploy-LogAnalyticsWorkspace() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $WorkspaceName,
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccessForIngestion = "Enabled",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccessForQuery = "Enabled",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Log Analytics Workspace $WorkspaceName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$WorkspaceName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    workspaceName="$WorkspaceName" `
    publicNetworkAccessForIngestion="$PublicNetworkAccessForIngestion" `
    publicNetworkAccessForQuery="$PublicNetworkAccessForQuery" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-MonitorDataCollectionEndpoint()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $DataCollectionEndpointName,
    [Parameter(Mandatory = $false)]
    [string]
    $DataCollectionEndpointKind = "Linux",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccess = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Data Collection Endpoint $DataCollectionEndpointName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DataCollectionEndpointName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    name="$DataCollectionEndpointName" `
    kind="$DataCollectionEndpointKind" `
    publicNetworkAccess="$PublicNetworkAccess" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-MonitorDataCollectionRule()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $DataCollectionRuleName,
    [Parameter(Mandatory = $true)]
    [string]
    $LogAnalyticsWorkspaceName,
    [Parameter(Mandatory = $true)]
    [string]
    $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Data Collection Endpoint $DataCollectionRuleName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DataCollectionRuleName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    dataCollectionRuleName="$DataCollectionRuleName" `
    logAnalyticsWorkspaceName="$LogAnalyticsWorkspaceName" `
    logAnalyticsWorkspaceResourceId="$LogAnalyticsWorkspaceResourceId" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-MonitorDataCollectionRuleAssociation()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $DataCollectionEndpointResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $DataCollectionRuleResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $ScopedResourceId
  )

  Write-Debug -Debug:$true -Message "Deploy Data Collection Rule Association"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    dataCollectionEndpointResourceId="$DataCollectionEndpointResourceId" `
    dataCollectionRuleResourceId="$DataCollectionRuleResourceId" `
    scopedResourceId="$ScopedResourceId" `
    | ConvertFrom-Json

  return $output
}

function Deploy-MonitorPrivateLinkScopeResourceConnection()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateLinkScopeName,
    [Parameter(Mandatory = $true)]
    [string]
    $ScopedResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $ScopedResourceName
  )

  Write-Debug -Debug:$true -Message "Connect Resource $ScopedResourceName to AMPLS $PrivateLinkScopeName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PrivateLinkScopeName-$ScopedResourceName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    linkScopeName=$PrivateLinkScopeName `
    scopedResourceId=$ScopedResourceId `
    scopedResourceName=$ScopedResourceName `
    | ConvertFrom-Json

  return $output
}

function Deploy-MonitorPrivateLinkScope()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateLinkScopeName,
    [Parameter(Mandatory = $false)]
    [string]
    $QueryAccessMode = "Open",
    [Parameter(Mandatory = $false)]
    [string]
    $IngestionAccessMode = "Open",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Azure Monitor Private Link Scope $PrivateLinkScopeName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PrivateLinkScopeName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location=global `
    linkScopeName=$PrivateLinkScopeName `
    queryAccessMode=$QueryAccessMode `
    ingestionAccessMode=$IngestionAccessMode `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Get-DiagnosticsSettingsForResource()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$false)]
    [string]
    $LogAnalyticsWorkspaceId = "",
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceName
  )
  Write-Debug -Debug:$true -Message "Get-DiagnosticsSettingsForResource $ResourceName"

  [System.Collections.ArrayList]$result = @()

  if ($LogAnalyticsWorkspaceId)
  {
    $query = "[?(workspaceId=='" + $LogAnalyticsWorkspaceId + "')].{name:name, id:id}"
  }
  else
  {
    $query = "[].{name:name, id:id}"
  }

  # Main resource diagnostic settings
  $settings = "$(az monitor diagnostic-settings list --subscription $SubscriptionId --resource $ResourceId --query "$query" 2>nul)" | ConvertFrom-Json

  if ($settings) { $result.Add($settings) | Out-Null }

  if ($ResourceId.EndsWith("Microsoft.Storage/storageAccounts/" + $ResourceName))
  {
    $rid = $ResourceId + "/blobServices/default"
    $settings = "$(az monitor diagnostic-settings list --subscription $SubscriptionId --resource $rid --query "$query" 2>nul)" | ConvertFrom-Json
    if ($settings) { $result.Add($settings) | Out-Null }

    $rid = $ResourceId + "/fileServices/default"
    $settings = "$(az monitor diagnostic-settings list --subscription $SubscriptionId --resource $rid --query "$query" 2>nul)" | ConvertFrom-Json
    if ($settings) { $result.Add($settings) | Out-Null }

    $rid = $ResourceId + "/queueServices/default"
    $settings = "$(az monitor diagnostic-settings list --subscription $SubscriptionId --resource $rid --query "$query" 2>nul)" | ConvertFrom-Json
    if ($settings) { $result.Add($settings) | Out-Null }

    $rid = $ResourceId + "/tableServices/default"
    $settings = "$(az monitor diagnostic-settings list --subscription $SubscriptionId --resource $rid --query "$query" 2>nul)" | ConvertFrom-Json
    if ($settings) { $result.Add($settings) | Out-Null }
  }

  return $result
}

function Get-DiagnosticsSettingsForSub()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$false)]
    [string]
    $LogAnalyticsWorkspaceId = ""
  )
  Write-Debug -Debug:$true -Message "Get-DiagnosticsSettingsForSub $ResourceName"

  [System.Collections.ArrayList]$result = @()

  if ($LogAnalyticsWorkspaceId)
  {
    $query = "(value)[?(workspaceId=='" + $LogAnalyticsWorkspaceId + "')].{name:name, id:id}"
  }
  else
  {
    $query = "(value)[].{name:name, id:id}"
  }

  $settings = "$(az monitor diagnostic-settings subscription list --subscription $SubscriptionId --query "$query" 2>nul)" | ConvertFrom-Json

  if ($settings) { $result.Add($settings) | Out-Null }

  return $result
}

function New-LogAnalyticsWorkspaceDataExport()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $LogAnalyticsWorkspaceName,
    [Parameter(Mandatory=$true)]
    [string]
    $DataExportName,
    [Parameter(Mandatory=$true)]
    [string]
    $DestinationResourceId,
    [Parameter(Mandatory=$false)]
    [string[]]
    $TableNames = $null
  )
  Write-Debug -Debug:$true -Message "New-LogAnalyticsWorkspaceDataExport $LogAnalyticsWorkspaceName on $ResourceId"

  if ($null -eq $TableNames -or $TableNames.Count -eq 0)
  {
    New-AzOperationalInsightsDataExport
      -ResourceGroupName "$ResourceGroupName" `
      -WorkspaceName "$LogAnalyticsWorkspaceName" `
      -DataExportName "$DataExportName" `
      -ResourceId "$DestinationResourceId"
  }
  else
  {
    New-AzOperationalInsightsDataExport
      -ResourceGroupName "$ResourceGroupName" `
      -WorkspaceName "$LogAnalyticsWorkspaceName" `
      -DataExportName "$DataExportName" `
      -ResourceId "$DestinationResourceId" `
      -TableName $TableNames
  }
}

function Remove-DiagnosticsSetting()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $DiagnosticsSettingName,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceName
  )
  Write-Debug -Debug:$true -Message "Remove-DiagnosticsSetting $DiagnosticsSettingName from $ResourceName"

  az monitor diagnostic-settings delete --subscription $SubscriptionId --name $DiagnosticsSettingName --resource $ResourceId
}

function Remove-DiagnosticsSettingsForAllResources()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$false)]
    [string]
    $LogAnalyticsWorkspaceId = ""
  )
  Write-Debug -Debug:$true -Message "Remove-DiagnosticsSettingsForAllResources on Log Analytics $LogAnalyticsWorkspaceId"

  $resources = "$(az resource list --subscription $SubscriptionId --query '[].{name:name, id:id}')" | ConvertFrom-Json

  foreach ($resource in $resources)
  {
    Remove-DiagnosticsSettingsForResource -SubscriptionId $SubscriptionId -LogAnalyticsWorkspaceId $LogAnalyticsWorkspaceId -ResourceId $resource.id -ResourceName $resource.name
  }
}

function Remove-DiagnosticsSettingsForResource()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$false)]
    [string]
    $LogAnalyticsWorkspaceId = "",
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceName
  )
  Write-Debug -Debug:$true -Message "Remove-DiagnosticsSettingsForResource $ResourceName"

  $settings = Get-DiagnosticsSettingsForResource -SubscriptionId $SubscriptionId -LogAnalyticsWorkspaceId $LogAnalyticsWorkspaceId -ResourceId $ResourceId -ResourceName $ResourceName

  if ($settings.Count -gt 0)
  {
    foreach ($setting in $settings)
    {
      Remove-DiagnosticsSetting `
        -SubscriptionId $SubscriptionId `
        -DiagnosticsSettingName $setting.name `
        -ResourceId $ResourceId `
        -ResourceName $ResourceName
    }
  }
}

function Remove-DiagnosticsSettingsForSub()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$false)]
    [string]
    $LogAnalyticsWorkspaceId = ""
  )
  Write-Debug -Debug:$true -Message "Remove-DiagnosticsSettingsForSub $SubscriptionId"

  $settings = Get-DiagnosticsSettingsForSub -SubscriptionId $SubscriptionId -LogAnalyticsWorkspaceId $LogAnalyticsWorkspaceId

  foreach ($setting in $settings)
  {
    $dgid = "/" + $setting.id
    az monitor diagnostic-settings subscription delete --ids $dgid --yes
  }
}


# ##################################################
# AzureNetwork.ps1
# ##################################################

function Deploy-NetworkNic()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $NicName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetResourceId,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableAcceleratedNetworking = $false,
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateIpAllocationMethod = "Dynamic",
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateIpAddress = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateIpAddressVersion = "IPv4",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicIpResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $IpConfigName = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy NIC $NicName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$NicName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    networkInterfaceName="$NicName" `
    subnetResourceId="$SubnetResourceId" `
    enableAcceleratedNetworking="$EnableAcceleratedNetworking" `
    privateIpAllocationMethod="$PrivateIpAllocationMethod" `
    privateIpAddress="$PrivateIpAddress" `
    privateIpAddressVersion="$PrivateIpAddressVersion" `
    publicIpResourceId="$PublicIpResourceId" `
    ipConfigName="$IpConfigName" `
    tags=$Tags `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkSecurityGroup() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGName,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy NSG $NSGName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$NSGName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    nsgName="$NSGName" `
    tags=$Tags `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkSecurityGroupRule() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGName,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGRuleName,
    [Parameter(Mandatory = $false)]
    [string]
    $Description = "",
    [Parameter(Mandatory = $false)]
    [int]
    $Priority = 200,
    [Parameter(Mandatory = $false)]
    [string]
    $Direction = "Inbound",
    [Parameter(Mandatory = $false)]
    [string]
    $Access = "Deny",
    [Parameter(Mandatory = $false)]
    [string]
    $Protocol = "Tcp",
    [Parameter(Mandatory = $false)]
    [string]
    $SourceAddressPrefix = "",
    [Parameter(Mandatory = $false)]
    [string]
    $SourceAddressPrefixes = "",
    [Parameter(Mandatory = $false)]
    [string]
    $SourcePortRange = "*",
    [Parameter(Mandatory = $false)]
    [string]
    $SourcePortRanges = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationAddressPrefix = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationAddressPrefixes = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationPortRange = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationPortRanges = ""
  )

  Write-Debug -Debug:$true -Message "Deploy NSG Rule $NSGRuleName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$NSGRuleName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    nsgName="$NSGName" `
    nsgRuleName="$NSGRuleName" `
    description="$Description" `
    priority="$Priority" `
    direction="$Direction" `
    access="$Access" `
    protocol="$Protocol" `
    sourceAddressPrefix="$SourceAddressPrefix" `
    sourceAddressPrefixes="$SourceAddressPrefixes" `
    sourcePortRange="$SourcePortRange" `
    sourcePortRanges="$SourcePortRanges" `
    destinationAddressPrefix="$DestinationAddressPrefix" `
    destinationAddressPrefixes="$DestinationAddressPrefixes" `
    destinationPortRange="$DestinationPortRange" `
    destinationPortRanges="$DestinationPortRanges" `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkPublicIp()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $PublicIpAddressName,
    [Parameter(Mandatory = $true)]
    [string]
    $PublicIpAddressType,
    [Parameter(Mandatory = $true)]
    [string]
    $PublicIpAddressSku,
    [Parameter(Mandatory = $false)]
    [string]
    $HostName = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )
  Write-Debug -Debug:$true -Message "Deploy PIP $PublicIpAddressName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PublicIpAddressName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    publicIpName="$PublicIpAddressName" `
    publicIpType="$PublicIpAddressType" `
    publicIpSku="$PublicIpAddressSku" `
    domainNameLabel="$HostName" `
    tags=$Tags `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkPrivateDnsZone()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $DnsZoneName,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Private DNS Zone $DnsZoneName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DnsZoneName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    privateDnsZoneName="$DnsZoneName" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkPrivateDnsZones()
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
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Private DNS Zones and VNet links"

  # Get the private DNS zone property names from the ConfigConstants object
  # Do this so we don't hard-code DNS zone names here, just grab whatever is configured on the config...
  $privateDnsZonePropNames = $ConfigConstants `
   | Get-Member -MemberType NoteProperty `
   | Select-Object -ExpandProperty Name `
   | Where-Object { $_.StartsWith("PrivateDnsZoneName") }


  $VNetResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ResourceProviderName "Microsoft.Network" -ResourceTypeName "virtualNetworks" -ResourceName $VNetName

  foreach ($privateDnsZonePropName in $privateDnsZonePropNames)
  {
    $zoneName = $ConfigConstants.$privateDnsZonePropName # Look it up - PSCustomObject... https://learn.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-pscustomobject#dynamically-accessing-properties

    $output = Deploy-NetworkPrivateDnsZone `
      -SubscriptionId $SubscriptionId `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.private-dns-zone.json") `
      -DnsZoneName $zoneName `
      -Tags $Tags

    Write-Debug -Debug:$true -Message "$output"

    $output = Deploy-NetworkPrivateDnsZoneVNetLink `
      -SubscriptionId $SubscriptionId `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.private-dns-zone.vnet-link.json") `
      -DnsZoneName $zoneName `
      -VNetResourceId $VNetResourceId `
      -Tags $Tags

    Write-Debug -Debug:$true -Message "$output"
  }
}

function Deploy-NetworkPrivateDnsZoneVNetLink()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $DnsZoneName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetResourceId,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Private DNS Zone VNet Link $DnsZoneName to $VNetResourceId"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DnsZoneName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    privateDnsZoneName="$DnsZoneName" `
    vnetResourceId="$VNetResourceId" `
    enableAutoRegistration=$false `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkPrivateEndpointAndNic()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $ProtectedWorkloadResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $ProtectedWorkloadSubResource,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateEndpointName,
    [Parameter(Mandatory = $true)]
    [string]
    $NetworkInterfaceName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetResourceId,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Private Endpoint and NIC $PrivateEndpointName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PrivateEndpointName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    protectedWorkloadResourceId="$ProtectedWorkloadResourceId" `
    protectedWorkloadSubResource="$ProtectedWorkloadSubResource" `
    privateEndpointName="$PrivateEndpointName" `
    networkInterfaceName="$NetworkInterfaceName" `
    subnetResourceId="$SubnetResourceId" `
    tags=$Tags `
    | ConvertFrom-Json

  Write-Debug -Debug:$true -Message "Wait for NIC provisioning to complete"
  Watch-NetworkNicUntilProvisionSuccess `
    -SubscriptionID "$SubscriptionId" `
    -ResourceGroupName "$ResourceGroupName" `
    -NetworkInterfaceName "$NetworkInterfaceName"

  return $output
}

function Deploy-NetworkPrivateEndpointPrivateDnsZoneGroup()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateEndpointName,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateDnsZoneName,
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateDnsZoneGroupName = "default",
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateDnsZoneResourceId
  )

  Write-Debug -Debug:$true -Message "Deploy Private Endpoint $PrivateEndpointName DNS Zone Group for $PrivateDnsZoneName"

  $zoneName = $PrivateDnsZoneName.Replace(".", "_")

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PrivateEndpointName-DNSZone" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    privateEndpointName="$PrivateEndpointName" `
    privateDnsZoneName="$zoneName" `
    privateDnsZoneGroupName="$PrivateDnsZoneGroupName" `
    privateDnsZoneResourceId="$PrivateDnsZoneResourceId" `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkSubnet() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetPrefix,
    [Parameter(Mandatory = $false)]
    [string]
    $NSGResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $RouteTableResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DelegationService = "",
    [Parameter(Mandatory = $false)]
    [string]
    $ServiceEndpoints = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Subnet $SubnetName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$SubnetName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    vnetName="$VNetName" `
    subnetName="$SubnetName" `
    subnetPrefix="$SubnetPrefix" `
    nsgResourceId="$NSGResourceId" `
    routeTableResourceId="$RouteTableResourceId" `
    delegationService="$DelegationService" `
    serviceEndpoints="$ServiceEndpoints" `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkVNet() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetPrefix,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableDdosProtection = $false,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableVmProtection = $false,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy VNet $VNetName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$VNetName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    vnetName="$VNetName" `
    vnetPrefix="$VNetPrefix" `
    enableDdosProtection="$EnableDdosProtection" `
    enableVmProtection="$EnableVmProtection" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Get-MyCurrentPublicIpAddress()
{
  $ipAddress = Invoke-RestMethod https://ipinfo.io/json | Select-Object -exp ip

  return $ipAddress
}

function Get-NetworkSubnetResourceIdForPrivateEndpoint()
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
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName
  )

  Write-Debug -Debug:$true -Message "Get Subnet Resource ID for Private Endpoint"

  $result = ""

  $subnetResourceIds = Get-NetworkSubnetResourceIds -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -SubscriptionId $SubscriptionId -ResourceGroupName "$ResourceGroupName" -VNetName $VNetName

  if ($subnetResourceIds -is [Array])
  {
    $result = $subnetResourceIds[0]
  }
  else
  {
    $result = $subnetResourceIds
  }

  return $result
}

function Get-NetworkSubnetResourceIds()
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
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName
  )

  Write-Debug -Debug:$true -Message "Get Subnet Resource IDs"

  $result = [System.Collections.ArrayList]@()

  $vnet = $ConfigMain.Network.VNet
  $VNetResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ResourceProviderName "Microsoft.Network" -ResourceTypeName "virtualNetworks" -ResourceName $VNetName

  foreach ($subnet in $vnet.Subnets)
  {
    $subnetResourceId = Get-ChildResourceId -ParentResourceId $VNetResourceId -ChildResourceTypeName "subnets" -ChildResourceName $subnet.Name

    $result.Add($subnetResourceId) | Out-Null
  }

  return $result
}

function Remove-NetworkSecurityGroupRule() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGName,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGRuleName
  )

  Write-Debug -Debug:$true -Message "Remove NSG Rule $NSGName/$NSGRuleName"

  $output = az network nsg rule delete --verbose `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    --nsg-name "$NSGName" `
    --name "$NSGRuleName" `
    | ConvertFrom-Json

  return $output
}

function Watch-NetworkNicUntilProvisionSuccess()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $NetworkInterfaceName
  )

  Write-Debug -Debug:$true -Message "Watch NIC $NetworkInterfaceName until ProvisioningStage=Succeeded"

  $limit = (Get-Date).AddMinutes(55)

  $currentState = ""
  $targetState = "Succeeded"

  while ( ($currentState -ne $targetState) -and ((Get-Date) -le $limit) )
  {
    $currentState = "$(az network nic show --subscription $SubscriptionId -g $ResourceGroupName -n $NetworkInterfaceName -o tsv --query 'provisioningState')"

    Write-Debug -Debug:$true -Message "currentState = $currentState"

    if ($currentState -ne $targetState)
    {
      Start-Sleep -s 15
    }
  }

  return $currentState
}


# ##################################################
# AzurePolicy.ps1
# ##################################################

function Get-PolicyAliases()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $NamespaceMatch
  )

  Get-AzPolicyAlias -NamespaceMatch "NamespaceMatch" | Select-Object namespace, resourcetype -ExpandProperty aliases
}

function Get-PolicyInfo()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId
  )

  # Get custom policy definitions
  $definitions = Get-AzPolicyDefinition -SubscriptionId $SubscriptionId -Custom

  # Get policy state summary for each custom policy definition
  ForEach ($definition in $definitions)
  {
    Write-Debug -Debug:$true -Message "Policy State Summary"
    Get-AzPolicyStateSummary -SubscriptionId $SubscriptionId -PolicyDefinitionName $definition.Name

    Write-Debug -Debug:$true -Message "Policy Assignments"
    $assignments = Get-AzPolicyAssignment -PolicyDefinitionId $definition.PolicyDefinitionId

    ForEach ($assignment in $assignments) {
      Write-Debug -Debug:$true -Message "Policy State for the Policy Assignment"
      Get-AzPolicyState -SubscriptionId $SubscriptionId -PolicyAssignmentName $assignment.Name
    }
  }
}

function New-PolicyAssignment()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $PolicyDefinitionName,
    [Parameter(Mandatory = $true)]
    [string]
    $AssignmentName,
    [Parameter(Mandatory = $true)]
    [string]
    $DisplayName,
    [Parameter(Mandatory = $true)]
    [string]
    $ParameterName,
    [Parameter(Mandatory = $true)]
    [string]
    $ParameterValue
  )

  # Get the resource group ID so we can set it as policy assignment audit scope
  # Scope can also be subscription or management group.
  $resource_group_id = (Get-AzResourceGroup -Name $ResourceGroupName).ResourceId

  # Get the policy definition for input to policy assignment
  $definition = Get-AzPolicyDefinition -Name $PolicyDefinitionName

  # Prepare parameter input object
  $parameter = @{$ParameterName = $ParameterValue}

  # Assign policy
  New-AzPolicyAssignment `
    -Name $AssignmentName `
    -DisplayName $DisplayName `
    -Scope $resource_group_id `
    -PolicyDefinition $definition `
    -PolicyParameterObject $parameter
}

function New-PolicyDefinition()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $PolicyDefinitionName,
    [Parameter(Mandatory = $true)]
    [string]
    $Category,
    [Parameter(Mandatory = $true)]
    [string]
    $DisplayName,
    [Parameter(Mandatory = $true)]
    [string]
    $Description,
    [Parameter(Mandatory = $true)]
    [string]
    $RulesUrl,
    [Parameter(Mandatory = $true)]
    [string]
    $ParamsUrl
  )

  # Create policy definition
  New-AzPolicyDefinition `
    -Name $PolicyDefinitionName `
    -Metadata ('{"category":"' + $Category + '"}') `
    -DisplayName $DisplayName `
    -Description $Description `
    -Policy $RulesUrl `
    -Parameter $ParamsUrl `
    -Mode All
}

# ##################################################
# AzureResource.ps1
# ##################################################

function Get-ChildResourceId()
{
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $ParentResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $ChildResourceTypeName,
    [Parameter(Mandatory = $true)]
    [string]
    $ChildResourceName
  )

  Write-Debug -Debug:$true -Message ("Get-ChildResourceId: ParentResourceId: " + "$ParentResourceId" + ", ChildResourceTypeName: " + "$ChildResourceTypeName" + ", ChildResourceName: " + "$ChildResourceName")

  $result = $ParentResourceId + "/" + $ChildResourceTypeName + "/" + $ChildResourceName

  return $result
}

function Get-ResourceId()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceProviderName,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceTypeName,
    [Parameter(Mandatory = $false)]
    [string]
    $ResourceSubTypeName = "",
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceName,
    [Parameter(Mandatory = $false)]
    [string]
    $ChildResourceTypeName = "",
    [Parameter(Mandatory = $false)]
    [string]
    $ChildResourceName = ""
  )

  Write-Debug -Debug:$true -Message ("Get-ResourceId: SubscriptionId: " + "$SubscriptionId" + ", ResourceGroupName: " + "$ResourceGroupName" + ", ResourceProviderName: " + "$ResourceProviderName" + ", ResourceTypeName: " + "$ResourceTypeName" + ", ResourceName: " + "$ResourceName" + ", ChildResourceTypeName: " + "$ChildResourceTypeName" + ", ChildResourceName: " + "$ChildResourceName")

  $result = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" + $ResourceGroupName + "/providers/" + $ResourceProviderName + "/" + $ResourceTypeName + "/"
  
  if ($ResourceSubTypeName)
  {
    $result += $ResourceSubTypeName + "/"
  }

  $result += $ResourceName

  if ($ChildResourceTypeName -and $ChildResourceName)
  {
    $result += "/" + $ChildResourceTypeName + "/" + $ChildResourceName
  }

  return $result
}

function Get-ResourceName()
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
    [Parameter(Mandatory = $false)]
    [string]
    $Prefix = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Sequence = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Suffix = "",
    [Parameter(Mandatory = $false)]
    [bool]
    $IncludeDelimiter = $true
  )

  Write-Debug -Debug:$true -Message ("Get-ResourceName: Prefix: " + "$Prefix" + ", Sequence: " + "$Sequence" + ", Suffix: " + "$Suffix" + ", IncludeDelimiter: " + "$IncludeDelimiter")

  if ($IncludeDelimiter)
  {
    $delimiter = "-"
  }
  else
  {
    $delimiter = ""
  }

  $result = ""

  if ($ConfigConstants.NamePrefix) { $result = $ConfigConstants.NamePrefix }
  if ($ConfigConstants.NameInfix) { $result += $delimiter + $ConfigConstants.NameInfix }

  if ($ConfigMain.LocationShort) { $result += $delimiter + $ConfigMain.LocationShort}

  if ($Prefix) { $result = $Prefix + $delimiter + $result }
  if ($Sequence) { $result += $delimiter + $Sequence }
  if ($Suffix) { $result += $delimiter + $Suffix }

  return $result
}

function Remove-ResourceGroup()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName
  )

  $rgExists = Test-ResourceGroupExists -rgName $ResourceGroupName

  if ($rgExists)
  {
    Write-Debug -Debug:$true -Message "Delete Resource Group locks for $ResourceGroupName"
    $lockIds = "$(az lock list -g $ResourceGroupName -o tsv --query '[].id')" | Where-Object { $_ }
    foreach ($lockId in $lockIds)
    {
      az lock delete --ids "$lockId"
    }

    Write-Debug -Debug:$true -Message "Delete Resource Group $ResourceGroupName"
    az group delete -n $ResourceGroupName --yes
  }
  else
  {
    Write-Debug -Debug:$true -Message "Resource Group $ResourceGroupName not found"
  }
}

function Test-ResourceExists()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceType,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceName
  )

  Write-Debug -Debug:$true -Message "Test-ResourceExists: SubscriptionId: $SubscriptionId, ResourceGroupName: $ResourceGroupName, ResourceType: $ResourceType, ResourceName: $ResourceName"

  $resourceId = az resource show `
    --subscription $SubscriptionId `
    -g $ResourceGroupName `
    --resource-type $ResourceType `
    -n $ResourceName `
    -o tsv `
    --query 'id' 2>&1

  if (!$?)
  {
    $resourceId = ""
  }

  if ($resourceId)
  {
    $resourceExists = $true
  }
  else
  {
    $resourceExists = $false
  }

  return $resourceExists
}

function Test-ResourceGroupExists()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName
  )

  Write-Debug -Debug:$true -Message "Test-ResourceGroupExists: SubscriptionId: $SubscriptionId, ResourceGroupName: $ResourceGroupName"

  $rgExists = [System.Convert]::ToBoolean("$(az group exists --subscription $SubscriptionId -n $ResourceGroupName)")

  return $rgExists
}


# ##################################################
# AzureSecurity.ps1
# ##################################################

function Deploy-RoleAssignmentSub()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $RoleDefinitionId,
    [Parameter(Mandatory = $true)]
    [string]
    $PrincipalId,
    [Parameter(Mandatory = $false)]
    [string]
    $PrincipalType = "ServicePrincipal"
  )

  $deploymentName = "rbac-" + $Location + "-" + (Get-Timestamp -MakeStringSafe $true)

  Write-Debug -Debug:$true -Message "Deploy Sub Role Assignment: RoleDefinitionId=$RoleDefinitionId, PrincipalId=$PrincipalId, PrincipalType=$PrincipalType"

  $output = az deployment sub create --verbose `
    -n "$deploymentName" `
    --location="$Location" `
    --template-uri "$TemplateUri" `
    --parameters `
    roleDefinitionId="$RoleDefinitionId" `
    principalId="$PrincipalId" `
    principalType="$PrincipalType" `
    | ConvertFrom-Json

  return $output
}

function Deploy-UserAssignedIdentity()
{
  <#
    .SYNOPSIS
    This command deploys an Azure User Assigned Identity.
    .DESCRIPTION
    This command deploys an Azure User Assigned Identity.
    .PARAMETER SubscriptionId
    The Azure subscription ID
    .PARAMETER Location
    The Azure region
    .PARAMETER ResourceGroupName
    The Resource Group name
    .PARAMETER TemplateUri
    The ARM template URI
    .PARAMETER TenantId
    The Azure tenant ID
    .PARAMETER UAIName
    The User Assigned Identity name
    .PARAMETER Tags
    Tags
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS> . ./Deploy-UAI.ps1
    PS> Deploy-UAI -SubscriptionID "MyAzureSubscriptionId" -Location "westus" -ResourceGroupName "MyResourceGroupName" -TemplateUri "MyARMTemplateURI" -TenantId "MyTenantId" -UAIName "MyUAIName" -Tags "MyTags"
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $TenantId,
    [Parameter(Mandatory = $true)]
    [string]
    $UAIName,
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy UAI $UAIName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$UAIName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    tenantId="$TenantId" `
    identityName="$UAIName" `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function New-ServicePrincipal()
{
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $ServicePrincipalName,
    [Parameter()]
    [string]
    $RoleName = "Owner"
  )

  $subscriptionId = "$(az account show -s $SubscriptionName -o tsv --query 'id')"

  az ad sp create-for-rbac --name "$ServicePrincipalName" --role "$RoleName" --scopes "/subscriptions/$subscriptionId" --verbose --sdk-auth
}

function Remove-RoleAssignments()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $false)]
    [string]
    $ResourceGroupName = "",
    [Parameter(Mandatory = $true)]
    [string]
    $PrincipalId
  )

  if ($ResourceGroupName)
  {
    $Scope = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" + $ResourceGroupName
  }
  else
  {
    $Scope = "/subscriptions/" + $SubscriptionId
  }

  # Have to do it this way because Powershell will make a one-item result into a string, not an array
  [System.Collections.ArrayList]$assignments = @()
  $a = "$(az role assignment list --scope $Scope --assignee $PrincipalId --query '[].id')" | ConvertFrom-Json
  $assignments.Add($a)
  # Have to trim out null items, which Powershell creates when adding arrays
  $assignments = $assignments.Where({ $null -ne $_ })

  if ($assignments.Count -eq 0)
  {
    Write-Debug -Debug:$true -Message "No role assignments found for $PrincipalId"
  }
  else
  {
    foreach ($assignment in $assignments)
    {
      Write-Debug -Debug:$true -Message "Delete Role Assignment $assignment"
      az role assignment delete --verbose --ids $assignment
    }
  }
}


# ##################################################
# AzureServiceBus.ps1
# ##################################################

function Set-SyncServiceBusNamespaceKeys()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $NamespaceNameSource,
    [Parameter(Mandatory = $true)]
    [string]
    $NamespaceNameDestination,
    [Parameter(Mandatory = $false)]
    [string]
    $SasPolicyName = "RootManageSharedAccessKey"
  )

  Write-Debug -Debug:$true -Message "Remove Key Vault $KeyVaultName Network Rule for $VNetName and $SubnetName"

  # This script synchronizes Azure Service Bus namespace keys from a source to a destination namespace.
  # Why use this? In case you have a scenario (e.g. active/active or active/passive) and you cannot refer to each namespace by individual connection string or key.
  # Example: JMS client failover-enabled connection string does not allow for specification of individual keys for each targeted namespace; only one key can be specified.

  # Source namespace RootManageSharedAccessKey
  primaryKey="$(az servicebus namespace authorization-rule keys list --subscription "$SubscriptionId" -g "$ResourceGroupName" --namespace-name "$NamespaceNameSource" -n "$SasPolicyName" -o tsv --query 'primaryKey')"
  secondaryKey="$(az servicebus namespace authorization-rule keys list --subscription "$SubscriptionId" -g "$ResourceGroupName" --namespace-name "$NamespaceNameSource" -n "$SasPolicyName" -o tsv --query 'secondaryKey')"

  # Set to destination namespace
  az servicebus namespace authorization-rule keys renew --subscription "$SubscriptionId" --verbose `
    -g "$ResourceGroupName" --namespace-name "$NamespaceNameDestination" -n "$SasPolicyName" `
    --key PrimaryKey --key-value "$primaryKey"

  az servicebus namespace authorization-rule keys renew --subscription "$SubscriptionId" --verbose `
    -g "$ResourceGroupName" --namespace-name "$NamespaceNameDestination" -n "$SasPolicyName" `
    --key SecondaryKey --key-value "$secondaryKey"
}

# ##################################################
# AzureStorage.ps1
# ##################################################

function Deploy-StorageAccount()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $SkuName,
    [Parameter(Mandatory = $false)]
    [string]
    $SkuTier = "Standard",
    [Parameter(Mandatory = $false)]
    [bool]
    $HierarchicalEnabled = $false,
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccess = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $AllowedSubnetResourceIdsCsv = "",
    [Parameter(Mandatory = $false)]
    [string]
    $AllowedIpAddressRangesCsv = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DefaultAction = "Deny",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Storage Account $StorageAccountName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$StorageAccountName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    storageAccountName="$StorageAccountName" `
    skuName=$SkuName `
    skuTier=$SkuTier `
    hierarchicalEnabled="$HierarchicalEnabled" `
    publicNetworkAccess="$PublicNetworkAccess" `
    allowedSubnetResourceIds="$AllowedSubnetResourceIdsCsv" `
    allowedIpAddressRanges="$AllowedIpAddressRangesCsv" `
    defaultAccessAction=$DefaultAction `
    tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-StorageDiagnosticsSetting()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $DiagnosticsSettingName,
    [Parameter(Mandatory = $true)]
    [string]
    $LogAnalyticsWorkspaceResourceId
  )

  Write-Debug -Debug:$true -Message "Deploy Storage Diagnostics Setting $DiagnosticsSettingName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DiagnosticsSettingName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    resourceId="$ResourceId" `
    diagnosticsSettingName="$DiagnosticsSettingName" `
    logAnalyticsWorkspaceResourceId="$LogAnalyticsWorkspaceResourceId" `
    | ConvertFrom-Json

  return $output
}

function New-StorageObjects()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $ContainerNames,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $QueueNames,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $TableNames
  )

  Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionName"
  az account set -s $SubscriptionName

  Write-Debug -Debug:$true -Message "Get key for $StorageAccountName"
  $accountKey = "$(az storage account keys list --account-name $StorageAccountName -o tsv --query '[0].value')"

  # Blob
  foreach ($containerName in $ContainerNames)
  {
    Write-Debug -Debug:$true -Message "Create container $containerName"
    az storage container create --account-name $StorageAccountName --account-key $accountKey -n $containerName
  }

  # Queue
  foreach ($queueName in $QueueNames)
  {
    Write-Debug -Debug:$true -Message "Create queue $queueName"
    az storage queue create --account-name $StorageAccountName --account-key $accountKey -n $queueName
  }

  # Table
  foreach ($tableName in $TableNames)
  {
    Write-Debug -Debug:$true -Message "Create table $tableName"
    az storage table create --account-name $StorageAccountName --account-key $accountKey -n $tableName
  }
}

function Remove-StorageContainersByNamePrefix()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $NamePrefix
  )

  Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionName"
  az account set -s $SubscriptionName

  $query = "[?starts_with(name, '" + $NamePrefix + "')].name"
  $containerNames = $(az storage container list --account-name $StorageAccountName --auth-mode login -o tsv --query $query)

  foreach ($containerName in $containerNames)
  {
    Write-Debug -Debug:$true -Message "Deleting container $containerName"
    az storage container delete --account-name $StorageAccountName -n $containerName --auth-mode login 
  }
  else
  {
    Write-Debug -Debug:$true -Message ("No Op on container $containerName")
  }
}

function Remove-StorageContainersByNamePrefixAndAge()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $NamePrefix,
    [Parameter(Mandatory = $true)]
    [int]
    $DaysOlderThan
  )

  Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionName"
  az account set -s $SubscriptionName

  $query = "[?starts_with(name, '" + $NamePrefix + "')].{Name: name, LastModified: properties.lastModified}"
  $containers = $(az storage container list --account-name $StorageAccountName --auth-mode login --query $query) | ConvertFrom-Json

  $daysBack = -1 * [Math]::Abs($DaysOlderThan) # Just in case someone passes a negative number to begin with
  $compareDate = (Get-Date).AddDays($daysBack)

  foreach ($container in $containers)
  {
    $deleteThis = ($compareDate -gt [DateTime]$container.LastModified)

    if ($deleteThis)
    {
      Write-Debug -Debug:$true -Message ("Deleting container " + $container.Name)
      az storage container delete --account-name $StorageAccountName -n $container.Name --auth-mode login 
    }
    else
    {
      Write-Debug -Debug:$true -Message ("No Op on container " + $container.Name)
    }
  }
}

function Remove-StorageObjects()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $ContainerNames,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $QueueNames,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $TableNames
  )

  Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionName"
  az account set -s $SubscriptionName

  Write-Debug -Debug:$true -Message "Get key for $StorageAccountName"
  $accountKey = "$(az storage account keys list --account-name $StorageAccountName -o tsv --query '[0].value')"

  # Blob
  foreach ($containerName in $ContainerNames)
  {
    Write-Debug -Debug:$true -Message "Delete container $containerName"
    az storage container delete --account-name $StorageAccountName --account-key $accountKey -n $containerName
  }

  # Queue
  foreach ($queueName in $QueueNames)
  {
    Write-Debug -Debug:$true -Message "Delete queue $queueName"
    az storage queue delete --account-name $StorageAccountName --account-key $accountKey -n $queueName
  }

  # Table
  foreach ($tableName in $TableNames)
  {
    Write-Debug -Debug:$true -Message "Delete table $tableName"
    az storage table delete --account-name $StorageAccountName --account-key $accountKey -n $tableName
  }
}

function Remove-StorageTablesByNamePrefix()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $NamePrefix
  )

  Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionName"
  az account set -s $SubscriptionName

  $query = "[?starts_with(name, '" + $NamePrefix + "')].name"
  $tableNames = $(az storage table list --account-name $StorageAccountName --auth-mode login -o tsv --query $query)

  foreach ($tableName in $tableNames)
  {
    Write-Debug -Debug:$true -Message "Deleting table $tableName"
    az storage table delete --account-name $StorageAccountName -n $tableName --auth-mode login 
  }
  else
  {
    Write-Debug -Debug:$true -Message ("No Op on table $tableName")
  }
}

function Remove-StorageTablesByNamePrefixAndAge()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $NamePrefix,
    [Parameter(Mandatory = $true)]
    [int]
    $DaysOlderThan
  )

  Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionName"
  az account set -s $SubscriptionName

  $query = "[?starts_with(name, '" + $NamePrefix + "')].name"
  $tableNames = $(az storage table list --account-name $StorageAccountName --auth-mode login -o tsv --query $query)

  $daysBack = -1 * [Math]::Abs($DaysOlderThan) # Just in case someone passes a negative number to begin with
  $compareDate = (Get-Date).AddDays($daysBack)

  foreach ($tableName in $tableNames)
  {
    # Get the date block in the table name
    $d1 = $tableName.Substring(3, 16)

    # Fix the string back to something Powershell DateTime can work with
    $d2 = `
      $d1.Substring(0, 4) + `
      "-" + `
      $d1.Substring(4, 2) + `
      "-" + `
      $d1.Substring(6, 5) + `
      ":" + `
      $d1.Substring(11, 2) + `
      ":" + `
      $d1.Substring(13)

    # Convert to DateTime for comparison
    $d3 = [DateTime]$d2

    $deleteThis = ($compareDate -gt $d3)

    if ($deleteThis)
    {
      Write-Debug -Debug:$true -Message ("Deleting table $tableName")
      az storage table delete --account-name $StorageAccountName -n $tableName --auth-mode login 
    }
    else
    {
      Write-Debug -Debug:$true -Message ("No Op on table $tableName")
    }
  }
}

function Set-StorageAccountPublicNetworkAccess()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $false)]
    [string]
    $DefaultAction = "Deny" # Allow or Deny
  )
  az storage account update --name $StorageAccountName --default-action $DefaultAction
}


# ##################################################
# AzureStorageCopy.ps1
# ##################################################

function Copy-StorageData()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $EnvironmentName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionNameSink,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountNameSink,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionNameSource,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountNameSource,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupNameDataFactory,
    [Parameter(Mandatory = $true)]
    [string]
    $DataFactoryName,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $ContainerNamesSource,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $TableNamesSource,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $ContainerNamesSink,
    [Parameter(Mandatory = $false)]
    [string[]]
    [AllowEmptyCollection()]
    $QueueNamesSink,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $TableNamesSink
  )
  # Expire SAS an hour from now in UTC
  $expiry = (Get-Date -AsUTC).AddMinutes(60).ToString("yyyy-MM-ddTHH:mmZ")

  Write-Debug -Debug:$true -Message "Set subscription to source $SubscriptionNameSource"
  az account set -s $SubscriptionNameSource

  Write-Debug -Debug:$true -Message "Get key for source account $StorageAccountNameSource"
  $accountKeySource = "$(az storage account keys list --account-name $StorageAccountNameSource -o tsv --query '[0].value')"

  Write-Debug -Debug:$true -Message "Create SAS for source account $StorageAccountNameSource"
  $sasSource = az storage account generate-sas -o tsv --only-show-errors `
    --account-name $StorageAccountNameSource `
    --account-key $accountKeySource `
    --expiry $expiry  `
    --services bfqt `
    --resource-types sco `
    --permissions lr `
    --https-only

  Write-Debug -Debug:$true -Message "Set subscription to sink $SubscriptionNameSink"
  az account set -s $SubscriptionNameSink

  Write-Debug -Debug:$true -Message "Get key for sink $StorageAccountNameSink"
  $accountKeySink = "$(az storage account keys list --account-name $StorageAccountNameSink -o tsv --query '[0].value')"

  Write-Debug -Debug:$true -Message "Create SAS for sink $StorageAccountNameSink"
  $sasSink = az storage account generate-sas -o tsv --only-show-errors `
    --account-name $StorageAccountNameSink `
    --account-key $accountKeySink `
    --expiry $expiry  `
    --services bfqt `
    --resource-types sco `
    --permissions acdfilprtuwxy `
    --https-only

  # Blobs
  Copy-StorageBlobs `
    -StorageAccountNameSource $StorageAccountNameSource `
    -StorageAccountNameSink $StorageAccountNameSink `
    -SasSource $sasSource `
    -SasSink $sasSink `
    -ContainerNamesSource $ContainerNamesSource `
    -ContainerNamesSink $ContainerNamesSink

  # Queues
  if ($QueueNamesSink -and $QueueNamesSink.Count -gt 0)
  {
    Set-StorageQueues `
      -StorageAccountNameSink $StorageAccountNameSink `
      -SasSink $sasSink `
      -QueueNames $QueueNamesSink
  }

  # Tables
  Copy-StorageTables `
    -Location $Location `
    -SubscriptionNameDataFactory $SubscriptionNameSource `
    -EnvironmentName $EnvironmentName `
    -StorageAccountNameSource $StorageAccountNameSource `
    -StorageAccountNameSink $StorageAccountNameSink `
    -AccountKeySource $accountKeySource `
    -AccountKeySink $accountKeySink `
    -ResourceGroupNameDataFactory $ResourceGroupNameDataFactory `
    -DataFactoryName $DataFactoryName `
    -TableNamesSource $TableNamesSource `
    -TableNamesSink $TableNamesSink
}

function Copy-StorageBlobs()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountNameSource,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountNameSink,
    [Parameter(Mandatory = $true)]
    [string]
    $SasSource,
    [Parameter(Mandatory = $true)]
    [string]
    $SasSink,
    [Parameter(Mandatory = $true)]
    [string[]]
    $ContainerNamesSource,
    [Parameter(Mandatory = $true)]
    [string[]]
    $ContainerNamesSink
  )

  if (($ContainerNamesSource.Count -eq 0) -or ($ContainerNamesSource.Count -ne $ContainerNamesSink.Count))
  {
    Write-Error "Provide source and sink container names arrays with >0 items and same item counts."
  }
  else
  {
    for ($i = 0; $i -lt $ContainerNamesSource.Count; $i++)
    {
      $containerNameSource = $ContainerNamesSource[$i]
      $containerNameSink = $ContainerNamesSink[$i]

      Write-Debug -Debug:$true -Message "Create sink container $containerNameSink"
      az storage container create --account-name $StorageAccountNameSink --sas-token $SasSink -n $containerNameSink

      Write-Debug -Debug:$true -Message "Run azcopy sync from source container $containerNameSource to sink container $containerNameSink"
      azcopy sync "https://$StorageAccountNameSource.blob.core.windows.net/$containerNameSource/?$SasSource" "https://$StorageAccountNameSink.blob.core.windows.net/$containerNameSink/?$SasSink"
    }
  }
}

function Copy-StorageTables()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionNameDataFactory,
    [Parameter(Mandatory = $true)]
    [string]
    $EnvironmentName,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountNameSource,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountNameSink,
    [Parameter(Mandatory = $true)]
    [string]
    $AccountKeySource,
    [Parameter(Mandatory = $true)]
    [string]
    $AccountKeySink,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupNameDataFactory,
    [Parameter(Mandatory = $true)]
    [string]
    $DataFactoryName,
    [Parameter(Mandatory = $true)]
    [string[]]
    $TableNamesSource,
    [Parameter(Mandatory = $true)]
    [string[]]
    $TableNamesSink
  )

  if (($TableNamesSource.Count -eq 0) -or ($TableNamesSource.Count -ne $TableNamesSink.Count))
  {
    Write-Error "Provide source and sink container names arrays with >0 items and same item counts."
  }
  else
  {
    Write-Debug -Debug:$true -Message "Setting subscription to $SubscriptionNameDataFactory"
    az account set -s $SubscriptionNameDataFactory

      # Variables
    $dfLsNameSource = $StorageAccountNameSource
    $dfLsNameSink = $StorageAccountNameSink

    Write-Debug -Debug:$true -Message "Create ADF RG $ResourceGroupNameDataFactory"
    $tags = Get-Tags -EnvironmentName $EnvironmentName
    az group create -n $ResourceGroupNameDataFactory -l $Location --tags $tags

    Write-Debug -Debug:$true -Message "Create ADF $DataFactoryName"
    az datafactory create `
      --location $Location `
      -g $ResourceGroupNameDataFactory `
      --factory-name $DataFactoryName

    Write-Debug -Debug:$true -Message "Create linked service $dfLsNameSource"
    $jsonLsSource = '{"annotations":[],"type":"AzureTableStorage","typeProperties":{"connectionString":"DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=' + $StorageAccountNameSource + ';AccountKey=' + $AccountKeySource + '"}}'
    $jsonLsSource > "ls-source.json"
    Write-Debug -Debug:$true -Message $jsonLsSource

    az datafactory linked-service create `
      -g $ResourceGroupNameDataFactory `
      --factory-name $DataFactoryName `
      --linked-service-name $dfLsNameSource `
      --properties '@ls-source.json'

    Write-Debug -Debug:$true -Message "Create linked service $dfLsNameSink"
    $jsonLsSink = '{"annotations":[],"type":"AzureTableStorage","typeProperties":{"connectionString":"DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=' + $StorageAccountNameSink + ';AccountKey=' + $AccountKeySink + '"}}'
    $jsonLsSink > "ls-sink.json"
    Write-Debug -Debug:$true -Message $jsonLsSink

    az datafactory linked-service create `
      -g $ResourceGroupNameDataFactory `
      --factory-name $DataFactoryName `
      --linked-service-name $dfLsNameSink `
      --properties '@ls-sink.json'

    for ($i = 0; $i -lt $TableNamesSource.Count; $i++)
    {
      $tableNameSource = $TableNamesSource[$i]
      $tableNameSink = $TableNamesSink[$i]

      Write-Debug -Debug:$true -Message "Create sink table $tableNameSink"
      az storage table create --account-name $StorageAccountNameSink --account-key $AccountKeySink -n $tableNameSink

      $dataSetNameSource = $dfLsNameSource + "_" + $tableNameSource
      Write-Debug -Debug:$true -Message "Create dataset $dataSetNameSource"
      $jsonDsSource = '{"linkedServiceName": {"referenceName": "' + $dfLsNameSource + '", "type": "LinkedServiceReference"}, "annotations": [], "type": "AzureTable", "schema": [], "typeProperties": {"tableName": "' + $tableNameSource + '"}}'
      $jsonDsSource > "dataset-source.json"
      Write-Debug -Debug:$true -Message $jsonDsSource

      az datafactory dataset create `
      -g $ResourceGroupNameDataFactory `
      --factory-name $DataFactoryName `
      --dataset-name $dataSetNameSource `
      --properties '@dataset-source.json'

      $dataSetNameSink = $dfLsNameSink + "_" + $tableNameSink
      Write-Debug -Debug:$true -Message "Create dataset $dataSetNameSink"
      $jsonDsSink = '{"linkedServiceName": {"referenceName": "' + $dfLsNameSink + '", "type": "LinkedServiceReference"}, "annotations": [], "type": "AzureTable", "schema": [], "typeProperties": {"tableName": "' + $tableNameSink + '"}}'
      $jsonDsSink > "dataset-sink.json"
      Write-Debug -Debug:$true -Message $jsonDsSink

      az datafactory dataset create `
        -g $ResourceGroupNameDataFactory `
        --factory-name $DataFactoryName `
        --dataset-name $dataSetNameSink `
        --properties '@dataset-sink.json'

      $pipelineName = $tableNameSource + "-" + $tableNameSink

      Write-Debug -Debug:$true -Message "Create pipeline $pipelineName"
      $jsonPipeline = '{"activities": [{"name": "Copy Data", "type": "Copy", "dependsOn": [], "policy": {"timeout": "0.12:00:00", "retry": 0, "retryIntervalInSeconds": 30, "secureOutput": false, "secureInput": false}, "userProperties": [], "typeProperties": {"source": {"type": "AzureTableSource", "azureTableSourceIgnoreTableNotFound": false}, "sink": {"type": "AzureTableSink", "azureTableInsertType": "merge", "azureTablePartitionKeyName": {"value": "PartitionKey", "type": "Expression"}, "azureTableRowKeyName": {"value": "RowKey", "type": "Expression"}, "writeBatchSize": 10000}, "enableStaging": false, "translator": {"type": "TabularTranslator", "typeConversion": true, "typeConversionSettings": {"allowDataTruncation": false, "treatBooleanAsNumber": false}}}, "inputs": [{"referenceName": "' + $dataSetNameSource + '", "type": "DatasetReference"}], "outputs": [{"referenceName": "' + $dataSetNameSink + '", "type": "DatasetReference"}]}], "annotations": []}'
      $jsonPipeline > "pipeline.json"
      Write-Debug -Debug:$true -Message $jsonPipeline

      az datafactory pipeline create `
        -g $ResourceGroupNameDataFactory `
        --factory-name $DataFactoryName `
        --pipeline-name $pipelineName `
        --pipeline '@pipeline.json'

      Write-Debug -Debug:$true -Message "Trigger pipeline $pipelineName"
      az datafactory pipeline create-run `
        -g $ResourceGroupNameDataFactory `
        --factory-name $DataFactoryName `
        --pipeline-name $pipelineName
    }
  }
}

function Set-StorageQueues()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]
    $Sas,
    [Parameter(Mandatory = $true)]
    [string[]]
    [AllowEmptyCollection()]
    $QueueNames
  )

  foreach ($queueName in $QueueNames)
  {
    Write-Debug -Debug:$true -Message "Create queue $queueName"
    az storage queue create --account-name $StorageAccountName -n $queueName --sas-token $Sas
  }
}



# ##################################################
# AzureUtility.ps1
# ##################################################

function Remove-AzPackages()
{
  Get-Package | Where-Object { $_.Name -like 'Az*' } | ForEach-Object { Uninstall-Package -Name $_.Name -AllVersions }
}


# ##################################################
# AzureVM.ps1
# ##################################################

function Deploy-Vm()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $VmName,
    [Parameter(Mandatory = $false)]
    [bool]
    $AssignSystemIdentity = $false,
    [Parameter(Mandatory = $true)]
    [string]
    $UaiResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $VmSize,
    [Parameter(Mandatory = $true)]
    [string]
    $VmPublisher,
    [Parameter(Mandatory = $true)]
    [string]
    $VmOffer,
    [Parameter(Mandatory = $true)]
    [string]
    $VmSku,
    [Parameter(Mandatory = $false)]
    [bool]
    $ProvisionVmAgent = $true,
    [Parameter(Mandatory = $true)]
    [string]
    $VmAdminUsername,
    [Parameter(Mandatory = $true)]
    [string]
    $VmAdminSshPublicKey,
    [Parameter(Mandatory = $false)]
    [string]
    $VmTimeZone = "",
    [Parameter(Mandatory = $true)]
    [string]
    $OsDiskName,
    [Parameter(Mandatory = $true)]
    [string]
    $OsDiskStorageType,
    [Parameter(Mandatory = $false)]
    [int]
    $OsDiskSizeInGB = 32,
    [Parameter(Mandatory = $false)]
    [string]
    $VmAutoShutdownTime = "9999",
    [Parameter(Mandatory = $false)]
    [string]
    $EnableAutoShutdownNotification = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $AutoShutdownNotificationWebhookURL = "",
    [Parameter(Mandatory = $false)]
    [int]
    $AutoShutdownNotificationMinutesBefore = 15,
    [Parameter(Mandatory = $true)]
    [string]
    $NetworkInterfaceResourceId,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableBootDiagnostics = $true,
    [Parameter(Mandatory = $false)]
    [string]
    $BootDiagnosticsStorageAccountName = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$true -Message "Deploy VM $VmName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$VmName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
      location="$Location" `
      assignSystemIdentity=$AssignSystemIdentity `
      userAssignedIdentityResourceId="$UaiResourceId" `
      virtualMachineName="$VmName" `
      virtualMachineSize="$VmSize" `
      publisher="$VmPublisher" `
      offer="$VmOffer" `
      sku="$VmSku" `
      provisionVmAgent=$ProvisionVmAgent `
      adminUsername="$VmAdminUsername" `
      adminSshPublicKey="$VmAdminSshPublicKey" `
      virtualMachineTimeZone="$VmTimeZone" `
      osDiskName="$OsDiskName" `
      osDiskStorageType="$OsDiskStorageType" `
      osDiskSizeInGB="$OsDiskSizeInGB" `
      vmAutoShutdownTime="$VmAutoShutdownTime" `
      enableAutoShutdownNotification="$EnableAutoShutdownNotification" `
      autoShutdownNotificationWebhookURL="$AutoShutdownNotificationWebhookURL" `
      autoShutdownNotificationMinutesBefore="$AutoShutdownNotificationMinutesBefore" `
      networkInterfaceResourceId="$NetworkInterfaceResourceId" `
      enableBootDiagnostics=$EnableBootDiagnostics `
      bootDiagnosticsStorageAccountName="$BootDiagnosticsStorageAccountName" `
      tags=$Tags `
    | ConvertFrom-Json

  return $output
}

function Deploy-VmAmaLinux()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $VmName
  )

  Write-Debug -Debug:$true -Message "Deploy VM $VmName AMA-Linux"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$VmName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    virtualMachineName="$VmName" `
    | ConvertFrom-Json

  return $output
}

# ##################################################
# Network.ps1
# ##################################################

$Debug = $false

#region General Network

function Get-MyPublicIpAddress() {
  <#
    .SYNOPSIS
    This function reaches out to a third-party web site and gets "my" public IP address, typically the egress address from my local network
    .DESCRIPTION
    This function reaches out to a third-party web site and gets "my" public IP address, typically the egress address from my local network
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS> $myPublicIpAddress = Get-MyPublicIpAddress
    .LINK
    None
  #>

  [CmdletBinding()]
  $ipUrl = "https://api.ipify.org"

  $myPublicIpAddress = ""

  # Test whether I can use a public site to get my public IP address
  $statusCode = (Invoke-WebRequest "$ipUrl").StatusCode

  if ("200" -eq "$statusCode") {
    # Get my public IP address
    $myPublicIpAddress = Invoke-RestMethod "$ipUrl"
    $myPublicIpAddress += "/32"

    Write-Debug -Debug:$true -Message "Got my public IP address: $myPublicIpAddress."
  }
  else {
    Write-Debug -Debug:$true -Message "Error! Could not get my public IP address."
  }

  return $myPublicIpAddress
}

#endregion

#region Azure IP addresses

function Get-AzurePublicIpRanges() {
  <#
    .SYNOPSIS
    This command retrieves the Service Tags with full info from the current Microsoft public IPs file download.
    .DESCRIPTION
    This command retrieves the Service Tags with full info from the current Microsoft public IPs file download.
    .INPUTS
    None
    .OUTPUTS
    Service Tags
    .EXAMPLE
    PS> Get-AzurePublicIpRanges
    .LINK
    None
  #>

  [CmdletBinding()]
  param()

  $fileMatch = "ServiceTags_Public"
  $ipRanges = @()

  $uri = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519"

  $response = Invoke-WebRequest -Uri $uri

  $links = $response.Links | Where-Object { $_.href -match $fileMatch }

  if ($links -and $links.Count -gt 0) {
    $link = $links[0]

    if ($link) {
      $jsonUri = $link.href

      $response = Invoke-WebRequest -Uri $jsonUri | ConvertFrom-Json

      if ($response -and $response.values) {
        $ipRanges = $response.values
      }
    }
  }

  return $ipRanges
}

function Get-AzurePublicIpV4Ranges() {
  <#
    .SYNOPSIS
    This command retrieves the Service Tags with full info from the current Microsoft public IPs file download. AddressPrefixes filtered to IPv4 only.
    .DESCRIPTION
    This command retrieves the Service Tags with full info from the current Microsoft public IPs file download. AddressPrefixes filtered to IPv4 only.
    .INPUTS
    None
    .OUTPUTS
    Service Tags
    .EXAMPLE
    PS> Get-AzurePublicIpV4Ranges
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
  )

  $ipRanges = Get-AzurePublicIpRanges

  if ($ipRanges) {
    foreach ($ipRange in $ipRanges) {
      $ipRange.Properties.AddressPrefixes = $ipRange.Properties.AddressPrefixes | Where-Object { $_ -like "*.*.*.*/*" }
    }
  }

  return $ipRanges
}

function Get-AzurePublicIpV4RangesForServiceTags() {
  <#
    .SYNOPSIS
    This command retrieves the IPv4 CIDRs for the specified Service Tags from the current Microsoft public IPs file download.
    .DESCRIPTION
    This command retrieves the IPv4 CIDRs for the specified Service Tags from the current Microsoft public IPs file download.
    .PARAMETER ServiceTags
    An array of one or more Service Tags from the Microsoft Public IP file at https://www.microsoft.com/en-us/download/details.aspx?id=53602.
    .INPUTS
    None
    .OUTPUTS
    Array of IPv4 CIDRs for the specified Service tags
    .EXAMPLE
    PS> Get-AzurePublicIpv4RangesForServiceTags -ServiceTags @("DataFactory.EastUS", "DataFactory.WestUS")
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string[]]
    $ServiceTags
  )

  $ips = @()

  $ipRanges = Get-AzurePublicIpV4Ranges

  if ($ipRanges) {
    foreach ($serviceTag in $ServiceTags) {
      $ipsForServiceTag = ($ipRanges | Where-Object { $_.name -eq $serviceTag })

      $ips += $ipsForServiceTag.Properties.AddressPrefixes
    }
  }

  $ips = $ips | Sort-Object

  return $ips
}

function Test-IsIpInCidr() {
  <#
    .SYNOPSIS
    This function checks if the specified IP address is contained in the specified CIDR.
    .DESCRIPTION
    This function checks if the specified IP address is contained in the specified CIDR.
    .PARAMETER IpAddress
    An IP address like 13.82.13.23 or 13.82.13.23/32
    .PARAMETER Cidr
    A CIDR, i.e. a network address range like 13.82.0.0/16
    .INPUTS
    None
    .OUTPUTS
    A bool indicating whether or not the IP address is contained in the CIDR
    .EXAMPLE
    PS> Test-IsIpInCidr -IpAddress "13.82.13.23/32" -Cidr "13.82.0.0/16"
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $IpAddress,
    [Parameter(Mandatory = $true)]
    [string]
    $Cidr
  )

  Write-Debug -Debug:$true -Message ("Test-IsIpInCidr :: IpAddress=" + $IpAddress + ", Cidr=" + $Cidr)

  $ip = $IpAddress.Split('/')[0]
  $cidrIp = $Cidr.Split('/')[0]
  $cidrBitsToMask = $Cidr.Split('/')[1]

  #Write-Debug -Debug:$true -Message ("ip=" + $ip + ", cidrIp=" + $cidrIp + ", cidrBitsToMask=" + $cidrBitsToMask)

  [int]$BaseAddress = [System.BitConverter]::ToInt32((([System.Net.IPAddress]::Parse($cidrIp)).GetAddressBytes()), 0)
  [int]$Address = [System.BitConverter]::ToInt32(([System.Net.IPAddress]::Parse($ip).GetAddressBytes()), 0)
  [int]$Mask = [System.Net.IPAddress]::HostToNetworkOrder(-1 -shl (32 - $cidrBitsToMask))

  #Write-Debug -Debug:$true -Message ("BaseAddress=" + $BaseAddress + ", Address=" + $Address + ", Mask=" + $Mask)

  $result = (($BaseAddress -band $Mask) -eq ($Address -band $Mask))

  #Write-Debug -Debug:$true -Message ("Result=" + $result)

  return $result
}

function Get-ServiceTagsForAzurePublicIp() {
  <#
    .SYNOPSIS
    This command retrieves the Service Tag(s) for the specified public IP address from the current Microsoft public IPs file download.
    .DESCRIPTION
    This command retrieves the Service Tag(s) for the specified public IP address from the current Microsoft public IPs file download. The output is a hashtable, so to use, set the output equal to a variable (see example) and work with that variable.
    .PARAMETER IpAddress
    An IP address like 13.82.13.23 or 13.82.13.23/32
    .INPUTS
    None
    .OUTPUTS
    Array of IPv4 CIDRs for the specified Service tags
    .EXAMPLE
    PS> $result = Get-ServiceTagsForAzurePublicIp -IpAddress "13.82.13.23"
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $IpAddress
  )

  $ipRanges = Get-AzurePublicIpRanges

  $result = @()

  Write-Debug -Debug:$true -Message "Processing - please wait... this will take a couple of minutes"

  foreach ($ipRange in $ipRanges)
  {
    $isFound = $false

    $ipRangeName = $ipRange.name
    $region = $ipRange.properties.region
    $cidrs = $ipRange.properties.addressPrefixes | Where-Object { $_ -like "*.*.*.*/*" } # filter to only IPv4

    Write-Debug -Debug:$true -Message "Checking ipRangeName = $ipRangeName"

    if (!$region) { $region = "(N/A)" }

    foreach ($cidr in $cidrs)
    {
      $ipIsInCidr = Test-IsIpInCidr -IpAddress $IpAddress -Cidr $cidr

      if ($ipIsInCidr)
      {
        $result +=
        @{
          Name   = $ipRangeName;
          Region = $region;
          Cidr   = $cidr;
        }

        $isFound = $true
      }

      if ($isFound -eq $true) {
        break
      }
    }
  }

  if ($isFound -eq $false) {
    Write-Debug -Debug:$true -Message ($IpAddress + ": Not found in any range")
  }

  , ($result | Sort-Object -Property "Name")
}

#endregion

#region Network Utility methods

# ##########
# Following utility methods include code from Chris Grumbles / Microsoft
# Updated logic, functionality, and style conformance
# ##########

function ConvertTo-BinaryIpAddress() {
  <#
    .SYNOPSIS
    This function converts a passed IP Address to binary
    .DESCRIPTION
    This function converts a passed IP Address to binary
    .PARAMETER IpAddress
    An IP address like 13.82.13.23 or 13.82.13.23/32
    .INPUTS
    None
    .OUTPUTS
    Binary IP address string
    .EXAMPLE
    PS> ConvertTo-BinaryIpAddress -IpAddress "13.82.13.23"
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $IpAddress
  )

  $ipAddressArray = $IpAddress.Split("/")
  $address = $ipAddressArray[0]

  if ($ipAddressArray.Count -gt 1) {
    $mask = $ipAddressArray[1]
  }
  else {
    $mask = "32"
  }

  $addressBinary = -Join ($address.Split(".") | ForEach-Object { ConvertTo-Binary -RawValue $_ })

  $maskIp = ConvertTo-IPv4MaskString -MaskBits $mask

  $maskBinary = -Join ($maskIp.Split(".") | ForEach-Object { ConvertTo-Binary -RawValue $_ })

  $result = $addressBinary + "/" + $maskBinary

  #Write-Debug -Debug:$true -Message ("ConvertTo-BinaryIpAddress :: IpAddress = " + $IpAddress + " :: Result = " + $result)

  return $result
}

function ConvertTo-Binary() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $RawValue,
    [Parameter(Mandatory = $false)]
    [string]
    $Padding = "0"
  )

  $result = [System.Convert]::ToString($RawValue, 2).PadLeft(8, $Padding)

  return $result
}

function ConvertFrom-BinaryIpAddress() {
  <#
    .SYNOPSIS
    This function converts a passed binary IP Address to normal CIDR-notation IP Address
    .DESCRIPTION
    This function converts a passed binary IP Address to normal CIDR-notation IP Address
    .PARAMETER IpAddressBinary
    A binary IP address like 11000000101010000000000000000000/11111111111111110000000000000000
    .INPUTS
    None
    .OUTPUTS
    Binary IP address string that is the output of ConvertTo-BinaryIpAddress
    .EXAMPLE
    PS> ConvertFrom-BinaryIpAddress -IpAddressBinary "11000000101010000000000000000000/11111111111111110000000000000000"
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $IpAddressBinary
  )

  $ipAddressArray = $IpAddressBinary.Split("/")

  $ipAddress = $ipAddressArray[0]
  $ipArray = @()

  for ($i = 0; $i -lt 4; $i++) {
    $ipArray += $ipAddress.Substring(($i) * 8, 8)
  }

  $ipFinal = $ipArray | ForEach-Object { [System.Convert]::ToByte($_, 2) }
  $ipFinal = $ipFinal -join "."

  if ($ipAddressArray.Count -gt 1) {
    $maskAddress = $ipAddressArray[1]

    $maskArray = @()

    for ($i = 0; $i -lt 4; $i++) {
      $maskArray += $maskAddress.Substring(($i) * 8, 8)
    }

    $maskFinal = $maskArray | ForEach-Object { [System.Convert]::ToByte($_, 2) }
    $maskFinal = $maskFinal -join "."

    $mask = ConvertTo-IPv4MaskBits -MaskString $maskFinal
  }
  #else
  #{
  #  $mask = "32"
  #}

  if ($mask) {
    $result = $ipFinal + "/" + $mask
  }
  else {
    $result = $ipFinal
  }

  #Write-Debug -Debug:$true -Message ("ConvertFrom-BinaryIpAddress :: IpAddressBinary = " + $IpAddressBinary + " :: Result = " + $result)

  return $result
}

function Get-EndIpForCidr() {
  <#
    .SYNOPSIS
    This function gets the end IP for a passed CIDR
    .DESCRIPTION
    This function gets the end IP for a passed CIDR
    .PARAMETER Cidr
    A CIDR like 13.23.0.0/16
    .INPUTS
    None
    .OUTPUTS
    An IP address like 13.23.254.254/32
    .EXAMPLE
    PS> Get-EndIpForCidr -Cidr "13.23.0.0/16"
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $Cidr
  )

  $startIp = $cidr.Split('/')[0]
  $prefix = [Convert]::ToInt32($cidr.Split('/')[1])

  $result = Get-EndIp -StartIp $startIp -Prefix $prefix

  #Write-Debug -Debug:$true -Message ("Get-EndIpForCidr :: Cidr = " + $Cidr + " :: Result = " + $result)

  return $result
}

function Get-EndIp() {
  <#
    .SYNOPSIS
    This function gets the end IP for a passed start IP and prefix
    .DESCRIPTION
    This function gets the end IP for a passed start IP and prefix
    .PARAMETER StartIp
    An IP address in the CIDR like 13.23.0.0
    .PARAMETER Prefix
    A prefix like 16
    .INPUTS
    None
    .OUTPUTS
    IP Address
    .EXAMPLE
    PS> Get-EndIp -IpAddress "13.23.0.0" -Prefix "16"
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $StartIp,
    [Parameter(Mandatory = $true)]
    [string]
    $Prefix
  )

  try {
    $ipCount = ([System.Math]::Pow(2, 32 - $Prefix)) - 1

    $startIpAdd = ([System.Net.IPAddress]$StartIp.Split("/")[0]).GetAddressBytes()

    # reverse bits & recreate IP
    [Array]::Reverse($startIpAdd)
    $startIpAdd = ([System.Net.IPAddress]($startIpAdd -join ".")).Address

    $endIp = [Convert]::ToDouble($startIpAdd + $ipCount)
    $endIp = [System.Net.IPAddress]$endIp

    $result = $endIp.ToString()

    #Write-Debug -Debug:$true -Message ("Get-EndIp: StartIp = " + $StartIp + " :: Prefix = " + $Prefix + " :: Result = " + $result)

    return $result
  }
  catch {
    Write-Debug -Debug:$true -Message "Get-EndIp: Could not find end IP for $($StartIp)/$($Prefix)"

    throw
  }
}

function Get-CidrRangeBetweenIps() {
  <#
    .SYNOPSIS
    This function gets CIDR range for a passed set  of IP addresses
    .DESCRIPTION
    This function gets CIDR range for a passed set  of IP addresses
    .PARAMETER IpAddresses
    An array of IP addresses
    .INPUTS
    None
    .OUTPUTS
    A CIDR range as a hashtable with keys startIp, endIp, prefix
    .EXAMPLE
    PS> Get-CidrRangeBetweenIps -IpAddresses @("13.23.13.0", "13.23.14.0")
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string[]]
    $IpAddresses
  )


  $binaryIps = [System.Collections.ArrayList]@()

  foreach ($ipAddress in $IpAddresses) {
    $binaryIp = ConvertTo-BinaryIpAddress -IpAddress $ipAddress
    $binaryIps.Add($binaryIp) | Out-Null
  }

  $binaryIps = $binaryIps | Sort-Object

  $smallestIp = $binaryIps[0]
  $biggestIp = $binaryIps[$binaryIps.Count - 1]

  #Write-Debug -Debug:$true -Message ("Get-CidrRangeBetweenIps :: IpAddresses = " + $IpAddresses + " :: SmallestIP = " + $smallestIp + " :: BiggestIP = " + $biggestIp)

  for ($i = 0; $i -lt $smallestIp.Length; $i++) {
    if ($smallestIp[$i] -ne $biggestIp[$i]) {
      break
    }
  }

  # deal with /31 as a special case
  if ($i -eq 31) { $i = 30 }

  $baseIp = $smallestIp.Substring(0, $i) + "".PadRight(32 - $i, "0")
  $baseIp2 = (ConvertFrom-BinaryIpAddress -IpAddress $baseIp)

  $result = @{startIp = $baseIp2; prefix = $i; endIp = "" }

  return $result
}

function Get-CidrRanges() {
  <#
    .SYNOPSIS
    This function gets CIDRs for a set of start/end IPs
    .DESCRIPTION
    This function gets CIDRs for a set of start/end IPs
    .PARAMETER IpAddresses
    An array of IP addresses
    .PARAMETER MaxSizePrefix
    Maximum CIDR prefix
    .PARAMETER AddCidrToSingleIPs
    Whether to append /32 to single IP addresses
    .INPUTS
    None
    .OUTPUTS
    An array of CIDRs
    .EXAMPLE
    PS> Get-CidrRanges -IpAddresses @("13.23.13.13", "13.23.13.244") -MaxSizePrefix 32 -AddCidrToSingleIPs $true
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string[]]
    $IpAddresses,
    [Parameter(Mandatory = $false)]
    [int]
    $MaxSizePrefix = 32,
    [Parameter(Mandatory = $false)]
    [bool]
    $AddCidrToSingleIPs = $true
  )

  Write-Debug -Debug:$true -Message ("Get-CidrRanges: MaxSizePrefix=" + $MaxSizePrefix + ", AddCidrToSingleIPs=" + $AddCidrToSingleIPs + ", IpAddresses=" + $IpAddresses)

  $ipAddressesBinary = [System.Collections.ArrayList]@()
  $ipAddressesSorted = [System.Collections.ArrayList]@()
  [string[]]$cidrRanges = @()

  # Convert each IP address to binary and add to array list
  foreach ($ipAddress in $IpAddresses) {
    $ipAddressBinary = ConvertTo-BinaryIpAddress -IpAddress $ipAddress
    $ipAddressesBinary.Add($ipAddressBinary) | Out-Null
  }

  # Sort the binary IP addresses
  $ipAddressesBinary = $ipAddressesBinary | Sort-Object

  # Convert the now-sorted binary IP addresses back into regular and add to array list
  foreach ($ipAddressBinary in $ipAddressesBinary) {
    $ipAddress = ConvertFrom-BinaryIpAddress -IpAddress $ipAddressBinary
    $ipAddressesSorted.Add($ipAddress) | Out-Null
  }

  $curRange = @{ startIp = $ipAddressesSorted[0]; prefix = 32 }

  for ($i = 0; $i -le $ipAddressesSorted.Count; $i++) {
    if ($i -lt $ipAddressesSorted.Count) {
      $testRange = Get-CidrRangeBetweenIps @($curRange.startIp, $ipAddressesSorted[$i])
    }

    if (($testRange.prefix -lt $MaxSizePrefix) -or ($i -eq $ipAddressesSorted.Count)) {
      # Too big. Apply the existing range & set the current IP to the start                
      $ipToAdd = $curRange.startIp

      if ((-not ($ipToAdd.Contains("/"))) -and (($AddCidrToSingleIPs -eq $true) -or ($curRange.prefix -lt 32))) {
        $ipToAdd += "/" + $curRange.prefix
      }

      $cidrRanges += $ipToAdd

      # reset the range to the current IP
      if ($i -lt $ipAddressesSorted.Count) {
        $curRange = @{ startIp = $ipAddressesSorted[$i]; prefix = 32 }
      }
    }
    else {
      $curRange = $testRange
    }
  }

  return $cidrRanges
}

function Get-CondensedCidrRanges() {
  <#
    .SYNOPSIS
    This function gets condensed CIDRs for a set of initial CIDRs
    .DESCRIPTION
    This function gets condensed CIDRs for a set of initial CIDRs
    .PARAMETER CidrRanges
    An array of CIDRs
    .PARAMETER MaxSizePrefix
    Maximum prefix for condensed CIDRs. This means that the prefix for a result CIDR will be no lower
    than this (bigger network), but can be higher if that is the smallest the CIDR can be.
    .PARAMETER AddCidrToSingleIPs
    Whether to append /32 to single IP addresses
    .INPUTS
    None
    .OUTPUTS
    An array of CIDRs - may be the original ones or consolidated if possible
    .EXAMPLE
    PS> Get-CondensedCidrRanges -CidrRanges @("13.23.13.0/16", "13.23.14.0/16", "13.24.4.0/16") -MaxSizePrefix 8 -AddCidrToSingleIPs $true
    .LINK
    None
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string[]]
    $CidrRanges,
    [Parameter(Mandatory = $false)]
    [int]
    $MaxSizePrefix = 32,
    [Parameter(Mandatory = $false)]
    [bool]
    $AddCidrToSingleIPs = $true
  )

  Write-Debug -Debug:$true -Message ("Get-CondensedCidrRanges :: MaxSizePrefix = " + $MaxSizePrefix + " :: AddCidrToSingleIPs = " + $AddCidrToSingleIPs + " :: CidrRanges = " + $CidrRanges)

  [string[]]$finalCidrRanges = @()
  $cidrObjs = @()

  # Convert each CIDR to Start/End/Count
  foreach ($cidr in $cidrRanges) {
    $startIp = $cidr.Split('/')[0]
    $prefix = $cidrBitsToMask = [Convert]::ToInt32($cidr.Split('/')[1])
    $ipCount = [Math]::Pow(2, 32 - $cidrBitsToMask)
    $endIp = Get-EndIp -StartIp $startIp -Prefix $prefix

    $cidrObj = @{ startIp = $startIp; endIp = $endIp; prefix = $prefix; ipCount = $ipCount }

    $cidrObjs += $cidrObj
  }

  # Try to merge CIDRs
  $curRange = $cidrObjs[0]

  for ($i = 0; $i -le $cidrObjs.Count; $i++) {
    if ($i -lt $cidrObjs.Count) {
      $testRange = (Get-CidrRangeBetweenIps @($curRange.startIp, $cidrObjs[$i].endIp))

      $testRange.endIp = Get-EndIp -StartIp $testRange.startIp -Prefix $testRange.prefix

      $isSameRange = ($testRange.startIp -eq $curRange.startIp) -and ($testRange.endIp -eq $curRange.endIp)

      if (($testRange.prefix -lt $MaxSizePrefix) -and ($isSameRange -eq $false)) {
        #Write-Debug -Debug:$true -Message ("Range too big")

        # This range is too big. Apply the existing range & set the current IP to the start
        $cidrToAdd = $curRange.startIp

        #if(($AddCidrToSingleIPs -eq $true) -or ($curRange.prefix -lt 32))
        if ((-not ($cidrToAdd.Contains("/"))) -and (($AddCidrToSingleIPs -eq $true) -or ($curRange.prefix -lt 32))) {
          $cidrToAdd += "/" + $curRange.prefix
        }

        $finalCidrRanges += $cidrToAdd

        # We added one, so reset the range to the current IP range
        if ($i -lt $cidrObjs.Count) {
          $curRange = $cidrObjs[$i]
        }
      }
      else {
        $curRange = $testRange
      }
    }
    else { 
      $cidrToAdd = $curRange.startIp

      if (($AddCidrToSingleIPs -eq $true) -or ($curRange.prefix -lt 32)) {
        $cidrToAdd += "/" + $curRange.prefix
      }

      $finalCidrRanges += $cidrToAdd
    }
  }

  $result = $finalCidrRanges | Get-Unique

  Write-Debug -Debug:$true -Message ("Get-CondensedCidrRanges :: Result Count = " + $result.Count + " :: Result = " + $result)

  return $result
}

# ##########

# ##########
# Following utility methods include code from Bill Stewart / https://www.itprotoday.com/powershell/working-ipv4-addresses-powershell
# Updated for style conformance and logic
# ##########
function ConvertTo-IPv4MaskString {
  param
  (
    [Parameter(Mandatory = $true)]
    [ValidateRange(0, 32)]
    [Int] $MaskBits
  )

  $mask = ([Math]::Pow(2, $MaskBits) - 1) * [Math]::Pow(2, (32 - $MaskBits))

  $bytes = [BitConverter]::GetBytes([UInt32] $mask)

  (($bytes.Count - 1)..0 | ForEach-Object { [String] $bytes[$_] }) -join "."
}

function Test-IPv4MaskString {
  param
  (
    [Parameter(Mandatory = $true)]
    [String] $MaskString
  )

  $validBytes = '0|128|192|224|240|248|252|254|255'

  $MaskString -match `
  ('^((({0})\.0\.0\.0)|' -f $validBytes) +
    ('(255\.({0})\.0\.0)|' -f $validBytes) +
    ('(255\.255\.({0})\.0)|' -f $validBytes) +
    ('(255\.255\.255\.({0})))$' -f $validBytes)
}

function ConvertTo-IPv4MaskBits {
  param
  (
    [parameter(Mandatory = $true)]
    [ValidateScript({ Test-IPv4MaskString $_ })]
    [String] $MaskString
  )

  $mask = ([IPAddress] $MaskString).Address

  for ( $bitCount = 0; $mask -ne 0; $bitCount++ ) {
    $mask = $mask -band ($mask - 1)
  }

  $bitCount
}
# ##########

#endregion

# ##################################################
# Utility.ps1
# ##################################################

function Get-ConfigFromFile()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $ConfigFilePath
  )

  Write-Debug -Debug:$true -Message ("Get-ConfigConstants: ConfigFilePath: " + "$ConfigFilePath")

  Get-Content -Path "$ConfigFilePath" | ConvertFrom-Json
}

function Get-EnvVars()
{
  Write-Debug -Debug:$true -Message ("Get-EnvVars")

  Get-ChildItem env:
}

function Get-Timestamp()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false)]
    [bool]
    $MakeStringSafe=$false
  )

  $result = (Get-Date -AsUTC -format s) + "Z"

  if ($MakeStringSafe)
  {
    $result = $result.Replace(":", "-")
  }

  return $result
}

function Get-TimestampForObjectNaming()
{
  ((Get-Timestamp).Replace(":", "").Replace("-", "")).ToLower()
}

function New-RandomString
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false)]
    [Int]
    $Length = 10
  )

  return $(-join ((97..122) + (48..57) | Get-Random -Count $Length | ForEach-Object {[char]$_}))
}

function Set-EnvVar2
{
  <#
    .SYNOPSIS
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .DESCRIPTION
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .PARAMETER VarName
    The environment variable name.
    .PARAMETER VarValue
    The environment variable value.
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS> . ./scripts/infra/Utility.ps1
    PS> Set-EnvVar2 -VarName "FOO" -VarValue "BAR"
    .LINK
    None
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $VarName,
    [Parameter(Mandatory = $true)]
    [string]
    $VarValue
  )

  Write-Debug -Debug:$true -Message ("Set-EnvVar2: VarName: " + "$VarName" + ", VarValue: " + "$VarValue")

  if ($env:GITHUB_ENV)
  {
    #Write-Host "GH"
    Write-Output "$VarName=$VarValue" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
  }
  else
  {
    #Write-Host "local"
    $cmd = "$" + "env:" + "$VarName='$VarValue'"
    #$cmd
    Invoke-Expression $cmd
  }
}

function Set-EnvVar1()
{
  <#
    .SYNOPSIS
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .DESCRIPTION
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .PARAMETER VarPair
    The environment variable name and value as VAR_NAME=VAR_VALUE
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS> . ./scripts/infra/Utility.ps1
    PS> Set-EnvVar1 -VarPair "FOO=BAR"
    .LINK
    None
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $VarPair
  )

  Write-Debug -Debug:$true -Message ("Set-EnvVar1: VarPair: " + "$VarPair")

  if ($VarPair -like "*=*")
  {
    $arr = $VarPair -split "="

    if ($arr.Count -eq 2)
    {
      Set-EnvVar2 -VarName $arr[0] -VarValue $arr[1]
    }
    else
    {
      Write-Host "You must pass a VarValue param like FOO=BAR, with a variable name separated from variable value by an equals sign. No change made."
    }
  }
  else
  {
    Write-Host "You must pass a VarValue param like FOO=BAR, with a variable name separated from variable value by an equals sign. No change made."
  }
}




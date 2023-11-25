$debug = $true

function Deploy-Network()
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
    $NSGName,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetResourceId,
    [Parameter(Mandatory = $false)]
    [string]
    $LogAnalyticsWorkspaceName = "",
    [Parameter(Mandatory = $false)]
    [string]
    $LogAnalyticsWorkspaceResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$debug -Message "Deploy Network"

  $nsg = $ConfigMain.Network.NSG

  $output = Deploy-NSG `
    -SubscriptionID "$SubscriptionId" `
    -Location $ConfigMain.Location `
    -ResourceGroupName $ResourceGroupName `
    -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.nsg.json") `
    -NSGName $NSGName `
    -Tags $Tags

  Write-Debug -Debug:$debug -Message "$output"

  if ($LogAnalyticsWorkspaceName -and $LogAnalyticsWorkspaceResourceId)
  {
    $output = Deploy-DiagnosticsSetting `
      -SubscriptionID "$SubscriptionId" `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "diagnostic-settings.json") `
      -ResourceId $NSGResourceId `
      -DiagnosticsSettingName ("diag-" + "$LogAnalyticsWorkspaceName") `
      -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId `
      -SendLogs $true `
      -SendMetrics $false
    
    Write-Debug -Debug:$debug -Message "$output"
  }

  foreach ($nsgRule in $nsg.Rules)
  {
    $output = Deploy-NSGRule `
      -SubscriptionID "$SubscriptionId" `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.nsg.rule.json") `
      -NSGName $NSGName `
      -NSGRuleName $nsgRule.Name `
      -Description $nsgRule.Description `
      -Priority $nsgRule.Priority `
      -Direction $nsgRule.Direction `
      -Access $nsgRule.Access `
      -Protocol $nsgRule.Protocol `
      -SourceAddressPrefix $nsgRule.SourceAddressPrefix `
      -SourcePortRange $nsgRule.SourcePortRange `
      -DestinationAddressPrefix $nsgRule.DestinationAddressPrefix `
      -DestinationPortRange $nsgRule.DestinationPortRange

    Write-Debug -Debug:$debug -Message "$output"
  }



  $vnet = $ConfigMain.Network.VNet

  $output = Deploy-VNet `
    -SubscriptionID "$SubscriptionId" `
    -Location $ConfigMain.Location `
    -ResourceGroupName $ResourceGroupName `
    -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.vnet.json") `
    -VNetName $VNetName `
    -VNetPrefix $vnet.AddressSpace `
    -EnableDdosProtection $vnet.EnableDdosProtection `
    -Tags $Tags

  Write-Debug -Debug:$debug -Message "$output"

  if ($LogAnalyticsWorkspaceName -and $LogAnalyticsWorkspaceResourceId)
  {
    $output = Deploy-DiagnosticsSetting `
      -SubscriptionID "$SubscriptionId" `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "diagnostic-settings.json") `
      -ResourceId $VNetResourceId `
      -DiagnosticsSettingName ("diag-" + "$LogAnalyticsWorkspaceName") `
      -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId `
      -SendLogs $true `
      -SendMetrics $true

    Write-Debug -Debug:$debug -Message "$output"
  }

  foreach ($subnet in $vnet.Subnets)
  {
    Write-Debug -Debug:$debug -Message $subnet.Name

    $output = Deploy-Subnet `
      -SubscriptionID "$SubscriptionId" `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.vnet.subnet.json") `
      -VNetName $VNetName `
      -SubnetName $subnet.Name `
      -SubnetPrefix $subnet.AddressSpace `
      -NsgResourceId $NSGResourceId `
      -RouteTableResourceId "" `
      -DelegationService $subnet.Delegation `
      -ServiceEndpoints $subnet.ServiceEndpoints

    Write-Debug -Debug:$debug -Message "$output"
  }
}

function Deploy-NSG() {
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

  Write-Debug -Debug:$debug -Message "Deploy NSG $NSGName"

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

function Deploy-NSGRule() {
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
    [Parameter(Mandatory = $true)]
    [string]
    $SourceAddressPrefix,
    [Parameter(Mandatory = $false)]
    [string]
    $SourcePortRange = "*",
    [Parameter(Mandatory = $true)]
    [string]
    $DestinationAddressPrefix,
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationPortRange = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationPortRanges = ""
  )

  Write-Debug -Debug:$debug -Message "Deploy NSG Rule $NSGRuleName"

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
    sourcePortRange="$SourcePortRange" `
    destinationAddressPrefix="$DestinationAddressPrefix" `
    destinationPortRange="$DestinationPortRange" `
    destinationPortRanges="$DestinationPortRanges" `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-VNet() {
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

  Write-Debug -Debug:$debug -Message "Deploy VNet $VNetName"

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

function Deploy-Subnet() {
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

  Write-Debug -Debug:$debug -Message "Deploy Subnet $SubnetName"

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

# -------------------------------

function Deploy-Pip()
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
  Write-Debug -Debug:$debug -Message "Deploy PIP $PublicIpAddressName"

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

function Deploy-Nic()
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

  Write-Debug -Debug:$debug -Message "Deploy NIC $NicName"

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

# -------------------------------

function Deploy-PrivateEndpointAndNic() {
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

  Write-Debug -Debug:$debug -Message "Deploy Private Endpoint and NIC $PrivateEndpointName"

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

  Write-Debug -Debug:$debug -Message "Wait for NIC provisioning to complete"
  Watch-NicUntilProvisionSuccess `
    -SubscriptionID "$SubscriptionId" `
    -ResourceGroupName "$ResourceGroupName" `
    -NetworkInterfaceName "$NetworkInterfaceName"

  return $output
}

function Deploy-PrivateEndpointPrivateDnsZoneGroup() {
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

  Write-Debug -Debug:$debug -Message "Deploy Private Endpoint $PrivateEndpointName DNS Zone Group for $PrivateDnsZoneName"

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

function Watch-NicUntilProvisionSuccess()
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

  Write-Debug -Debug:$debug -Message "Watch NIC $NetworkInterfaceName until ProvisioningStage=Succeeded"

  $limit = (Get-Date).AddMinutes(55)

  $currentState = ""
  $targetState = "Succeeded"

  while ( ($currentState -ne $targetState) -and ((Get-Date) -le $limit) )
  {
    $currentState = "$(az network nic show --subscription $SubscriptionId -g $ResourceGroupName -n $NetworkInterfaceName -o tsv --query 'provisioningState')"

    Write-Debug -Debug:$debug -Message "currentState = $currentState"

    if ($currentState -ne $targetState)
    {
      Start-Sleep -s 15
    }
  }

  return $currentState
}

function Deploy-PrivateDnsZones()
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

  Write-Debug -Debug:$debug -Message "Deploy Private DNS Zones and VNet links"

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

    $output = Deploy-PrivateDnsZone `
      -SubscriptionId $SubscriptionId `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.private-dns-zone.json") `
      -DnsZoneName $zoneName `
      -Tags $Tags

    Write-Debug -Debug:$debug -Message "$output"

    $output = Deploy-PrivateDnsZoneVNetLink `
      -SubscriptionId $SubscriptionId `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.private-dns-zone.vnet-link.json") `
      -DnsZoneName $zoneName `
      -VNetResourceId $VNetResourceId `
      -Tags $Tags

    Write-Debug -Debug:$debug -Message "$output"
  }
}

function Deploy-PrivateDnsZone()
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

  Write-Debug -Debug:$debug -Message "Deploy Private DNS Zone $DnsZoneName"

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

function Deploy-PrivateDnsZoneVNetLink()
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

  Write-Debug -Debug:$debug -Message "Deploy Private DNS Zone VNet Link $DnsZoneName to $VNetResourceId"

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

function Get-SubnetResourceIds()
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

  Write-Debug -Debug:$debug -Message "Get Subnet Resource IDs"

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


function Get-SubnetResourceIdForPrivateEndpoint()
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

  Write-Debug -Debug:$debug -Message "Get Subnet Resource ID for Private Endpoint"

  $result = ""

  $subnetResourceIds = Get-SubnetResourceIds -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -SubscriptionId $SubscriptionId -ResourceGroupName "$ResourceGroupName" -VNetName $VNetName

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

# -------------------------------

function Get-MyCurrentPublicIpAddress()
{
  $ipAddress = Invoke-RestMethod https://ipinfo.io/json | Select-Object -exp ip

  return $ipAddress
}
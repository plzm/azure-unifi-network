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
    $LogAnalyticsWorkspaceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Tags = ""
  )

  Write-Debug -Debug:$debug -Message "Deploy Network"

  $nsg = $ConfigMain.Network.NSG

  $output = plzm.Azure\Deploy-NetworkSecurityGroup `
    -SubscriptionID "$SubscriptionId" `
    -Location $ConfigMain.Location `
    -ResourceGroupName $ResourceGroupName `
    -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.nsg.json") `
    -NSGName $NSGName `
    -Tags $Tags

  Write-Debug -Debug:$debug -Message "$output"

  if ($LogAnalyticsWorkspaceName -and $LogAnalyticsWorkspaceId)
  {
    $output = plzm.Azure\Deploy-DiagnosticsSetting `
      -SubscriptionID "$SubscriptionId" `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "diagnostic-settings.json") `
      -ResourceId $NSGResourceId `
      -DiagnosticsSettingName ("diag-" + "$LogAnalyticsWorkspaceName") `
      -LogAnalyticsWorkspaceId $LogAnalyticsWorkspaceId `
      -SendLogs $true `
      -SendMetrics $false
    
    Write-Debug -Debug:$debug -Message "$output"
  }

  foreach ($nsgRule in $nsg.Rules)
  {
    $output = plzm.Azure\Deploy-NetworkSecurityGroupRule `
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
      -DestinationPortRange $nsgRule.DestinationPortRange `
      -DestinationPortRanges $nsgRule.DestinationPortRanges

    Write-Debug -Debug:$debug -Message "$output"
  }



  $vnet = $ConfigMain.Network.VNet

  $output = plzm.Azure\Deploy-NetworkVNet `
    -SubscriptionID "$SubscriptionId" `
    -Location $ConfigMain.Location `
    -ResourceGroupName $ResourceGroupName `
    -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.vnet.json") `
    -VNetName $VNetName `
    -VNetPrefix $vnet.AddressSpace `
    -EnableDdosProtection $vnet.EnableDdosProtection `
    -Tags $Tags

  Write-Debug -Debug:$debug -Message "$output"

  if ($LogAnalyticsWorkspaceName -and $LogAnalyticsWorkspaceId)
  {
    $output = plzm.Azure\Deploy-DiagnosticsSetting `
      -SubscriptionID "$SubscriptionId" `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "diagnostic-settings.json") `
      -ResourceId $VNetResourceId `
      -DiagnosticsSettingName ("diag-" + "$LogAnalyticsWorkspaceName") `
      -LogAnalyticsWorkspaceId $LogAnalyticsWorkspaceId `
      -SendLogs $true `
      -SendMetrics $true

    Write-Debug -Debug:$debug -Message "$output"
  }

  foreach ($subnet in $vnet.Subnets)
  {
    Write-Debug -Debug:$debug -Message $subnet.Name

    $output = plzm.Azure\Deploy-NetworkSubnet `
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


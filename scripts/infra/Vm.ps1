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
    $ProvisionVmAgent = $true
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
      adminUsername="" `
      adminSshPublicKey="" `
      virtualMachineTimeZone="" `
      osDiskName="" `
      osDiskStorageType="" `
      osDiskSizeInGB="" `
      vmAutoShutdownTime="" `
      enableAutoShutdownNotification="" `
      autoShutdownNotificationWebhookURL="" `
      autoShutdownNotificationMinutesBefore="" `
      resourceGroupNameNetworkInterface="$RG_NAME_VM_PROD" `
      networkInterfaceResourceId="" `
      enableBootDiagnostics=$true `
      bootDiagnosticsStorageAccountName="" `
      tags=$Tags `
    | ConvertFrom-Json

  return $output
}

}

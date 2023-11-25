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

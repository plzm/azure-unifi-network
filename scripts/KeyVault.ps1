function Get-SshKeyPairToLocalFiles()
{
  param
  (
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigConstants,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $KeyVaultName,
    [Parameter(Mandatory=$true)]
    [string]
    $ControllerVmName,
    [Parameter(Mandatory=$true)]
    [string]
    $IdForNaming,
    [Parameter(Mandatory=$false)]
    [string]
    $LocalFolderPath = ""
  )

  Write-Debug -Debug:$debug -Message "Get-SshKeyPairToLocalFiles : ControllerVmName=$ControllerVmName, IdForNaming=$IdForNaming, LocalFolderPath=$LocalFolderPath"

  if (!$LocalFolderPath)
  {
    $LocalFolderPath = $ConfigConstants.SshPath
    Write-Debug -Debug:$true -Message "LocalFolderPath: $LocalFolderPath"
  }

  $SshPrivateKeyName = $ConfigConstants.SshKeyNamePrefix + "$IdForNaming"
  $SshPublicKeyName = "$SshPrivateKeyName" + $ConfigConstants.SshPublicKeyFileExtension

  $SshPrivateKeyFilePath = Join-Path -Path $LocalFolderPath -ChildPath $SshPrivateKeyName
  $SshPublicKeyFilePath = Join-Path -Path $LocalFolderPath -ChildPath $SshPublicKeyName

  $SshPrivateKeySecretName = "$ControllerVmName" + $ConfigConstants.SuffixSecretNameSshPrivateKey
  $SshPublicKeySecretName = "$ControllerVmName" + $ConfigConstants.SuffixSecretNameSshPublicKey

  Write-Debug -Debug:$true -Message "SshPrivateKeyName: $SshPrivateKeyName"
  Write-Debug -Debug:$true -Message "SshPublicKeyName: $SshPublicKeyName"
  Write-Debug -Debug:$true -Message "SshPrivateKeyFilePath: $SshPrivateKeyFilePath"
  Write-Debug -Debug:$true -Message "SshPublicKeyFilePath: $SshPublicKeyFilePath"
  Write-Debug -Debug:$true -Message "SshPrivateKeySecretName: $SshPrivateKeySecretName"
  Write-Debug -Debug:$true -Message "SshPublicKeySecretName: $SshPublicKeySecretName"

  # Get my Public IP address
  $PublicIp = plzm.Azure\Get-MyCurrentPublicIpAddress
  Write-Debug -Debug:$true -Message "PublicIp: $PublicIp"

  # Open Key Vault Network Access
  plzm.Azure\Set-KeyVaultNetworkSettings `
    -SubscriptionId $SubscriptionId `
    -ResourceGroupName $ResourceGroupName `
    -KeyVaultName $KeyVaultName `
    -PublicNetworkAccess "Enabled" `
    -DefaultAction "Deny"

  # Add my current public IP allowed
  plzm.Azure\New-KeyVaultNetworkRuleForIpAddressOrRange `
    -SubscriptionId $SubscriptionId `
    -ResourceGroupName $ResourceGroupName `
    -KeyVaultName $KeyVaultName `
    -IpAddressOrRange $PublicIp

  # Get Private key
  $privateKey = plzm.Azure\Get-KeyVaultSecret `
    -SubscriptionId $SubscriptionId `
    -KeyVaultName $KeyVaultName `
    -SecretName $SshPrivateKeySecretName

  $privateKey | Out-File -FilePath $SshPrivateKeyFilePath -Force

  # Get Public key
  $publicKey = plzm.Azure\Get-KeyVaultSecret `
    -SubscriptionId $SubscriptionId `
    -KeyVaultName $KeyVaultName `
    -SecretName $SshPublicKeySecretName

  $publicKey | Out-File -FilePath $SshPublicKeyFilePath -Force

  # Remove my current public IP allowed
  plzm.Azure\Remove-KeyVaultNetworkRuleForIpAddressOrRange `
    -SubscriptionId $SubscriptionId `
    -ResourceGroupName $ResourceGroupName `
    -KeyVaultName $KeyVaultName `
    -IpAddressOrRange $PublicIp

  # Close Key Vault Network Access
  plzm.Azure\Set-KeyVaultNetworkSettings `
    -SubscriptionId $SubscriptionId `
    -ResourceGroupName $ResourceGroupName `
    -KeyVaultName $KeyVaultName `
    -PublicNetworkAccess "Disabled" `
    -DefaultAction "Deny"
}

. ./Utility.ps1
. ./Network.ps1

$ConfigConstants = Get-ConfigFromFile -ConfigFilePath "../../config/infra_constants.json"
$ConfigMain = Get-ConfigFromFile -ConfigFilePath "../../config/infra_main.json"
$ConfigController = Get-ConfigFromFile -ConfigFilePath "../../config/infra_controller.json"

$SubscriptionId = "$(az account show --query id --output tsv)"
$ResourceGroupName = "rsg-aa-ui-eus2-main"
$NSGRuleName = "000"
$TemplateUri = "https://raw.githubusercontent.com/plzm/azure-deploy/develop/template/net.nsg.rule.json"
$NSGName = "nsg-aa-ui-eus2-150"
#$Description = ""
#$Priority = 200
#$Direction = "Inbound"
#$Access = "Allow"
#$Protocol = "*"
#$SourceAddressPrefix = "75.68.47.183"
#$SourcePortRange = "*"
#$DestinationAddressPrefix = "VirtualNetwork"
#$DestinationPortRange = ""
#$DestinationPortRanges = "80,443,8443,3478,8080,8880,8843"

$nsgRule = $ConfigController.Network.NSG.Rules[0]

$output = Deploy-NSGRule `
  -SubscriptionID "$subscriptionId" `
  -ResourceGroupName "$ResourceGroupName" `
  -TemplateUri "$TemplateUri" `
  -NSGName "$NSGName" `
  -NSGRuleName $nsgRuleName `
  -Description $nsgRule.Description `
  -Priority ($ConfigConstants.NsgPriorityBase + $ConfigController.Id) `
  -Direction $nsgRule.Direction `
  -Access $nsgRule.Access `
  -Protocol $nsgRule.Protocol `
  -SourceAddressPrefix $nsgRule.SourceAddressPrefix `
  -SourcePortRange $nsgRule.SourcePortRange `
  -DestinationAddressPrefix $nsgRule.DestinationAddressPrefix `
  -DestinationPortRanges $nsgRule.DestinationPortRanges

#$output = az deployment group create --verbose --debug `
#  --subscription "$SubscriptionId" `
#  -n "$NSGRuleName" `
#  -g "$ResourceGroupName" `
#  --template-uri "$TemplateUri" `
#  --parameters `
#  nsgName="$NSGName" `
#  nsgRuleName="$NSGRuleName" `
#  description="$Description" `
#  priority="$Priority" `
#  direction="$Direction" `
#  access="$Access" `
#  protocol="$Protocol" `
#  sourceAddressPrefix="$SourceAddressPrefix" `
#  sourcePortRange="$SourcePortRange" `
#  destinationAddressPrefix="$DestinationAddressPrefix" `
#  destinationPortRange="$DestinationPortRange" `
#  destinationPortRanges="$DestinationPortRanges" `
#  | ConvertFrom-Json

Write-Output $output
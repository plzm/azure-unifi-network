$debug = $true

. ./scripts/infra/Utility.ps1

$configConstants = Get-ConfigFromFile -ConfigFilePath "./config/infra_constants.json"
$configMain = Get-ConfigFromFile -ConfigFilePath "./config/infra_main.json"


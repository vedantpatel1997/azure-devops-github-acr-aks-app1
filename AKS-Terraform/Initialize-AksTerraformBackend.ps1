[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern("^[a-z0-9-]+$")]
  [string]$Environment
)

$stateKey = "aks-$Environment.tfstate"

Write-Host "Initializing Terraform backend for environment '$Environment' using state key '$stateKey'..."

terraform init `
  -reconfigure `
  -backend-config="key=$stateKey"

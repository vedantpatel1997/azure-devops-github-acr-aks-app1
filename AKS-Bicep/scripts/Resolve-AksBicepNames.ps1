[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('dev', 'qa', 'prod')]
    [string]$Environment,

    [Parameter()]
    [string]$Location = 'westus2',

    [Parameter()]
    [string]$OrganizationName = 'vp'
)

$environmentSlug = $Environment.ToLowerInvariant()
$locationSlug = $Location.ToLowerInvariant().Replace(' ', '')
$envNoDash = $environmentSlug.Replace('-', '')

$nodePoolEnvironmentTag = if ($envNoDash.Length -ge 3) {
    $envNoDash.Substring(0, 3)
}
else {
    $envNoDash
}

$windowsNodePoolTag = if ($envNoDash.Length -ge 2) {
    $envNoDash.Substring(0, 2)
}
else {
    $envNoDash
}

$nameSuffix = "$OrganizationName-aks-$environmentSlug-$locationSlug"
$clusterSuffix = "$OrganizationName-$environmentSlug-$locationSlug"
$clusterName = "aks-$clusterSuffix"
$clusterAdminGroupUniqueName = "grp-aksadmin-$clusterName"

$result = [ordered]@{
    environment                 = $Environment
    location                    = $Location
    organizationName            = $OrganizationName
    resourceGroupName           = "rg-$nameSuffix"
    clusterName                 = $clusterName
    nodeResourceGroupName       = "rg-$nameSuffix-nodes"
    logAnalyticsWorkspaceName   = "log-$nameSuffix"
    virtualNetworkName          = "vnet-$nameSuffix"
    systemSubnetName            = "snet-$nameSuffix-system"
    linuxUserSubnetName         = "snet-$nameSuffix-linux"
    windowsUserSubnetName       = "snet-$nameSuffix-windows"
    clusterAdminGroupName       = $clusterAdminGroupUniqueName
    clusterAdminGroupUniqueName = $clusterAdminGroupUniqueName
    systemNodePoolName          = "sys$nodePoolEnvironmentTag" + "01"
    linuxUserNodePoolName       = "lin$nodePoolEnvironmentTag" + "01"
    windowsUserNodePoolName     = "win$windowsNodePoolTag" + "1"
    graphGroupDeleteUrl         = "https://graph.microsoft.com/v1.0/groups(uniqueName='$clusterAdminGroupUniqueName')"
}

$result | ConvertTo-Json -Depth 10

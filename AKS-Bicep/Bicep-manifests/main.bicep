targetScope = 'subscription'

@description('Azure region where the AKS platform resources will be deployed.')
param location string = 'westus2'

@description('Short environment name used in resource naming. Supported values are dev, qa, and prod.')
@allowed([
  'dev'
  'qa'
  'prod'
])
param environment string = 'dev'

@description('Short organization or team identifier used in resource naming.')
param organizationName string = 'vp'

@description('Pinned AKS Kubernetes version for the control plane and node pools.')
param kubernetesVersion string = '1.34.3'

@description('Additional Azure tags to merge with the template defaults.')
param additionalTags object = {}

@description('Object ID of the Microsoft Entra group configured as the AKS admin group.')
param aksAdminGroupObjectId string

@description('Display name of the Microsoft Entra group configured as the AKS admin group.')
param aksAdminGroupDisplayName string

@description('Unique name of the Microsoft Entra group configured as the AKS admin group.')
param aksAdminGroupUniqueName string

@description('SSH public key data used for Linux node access.')
param sshPublicKeyData string

@description('Linux administrator username for AKS Linux nodes.')
param linuxAdminUsername string = 'ubuntu'

@description('Windows administrator username for AKS Windows nodes.')
param windowsAdminUsername string = 'azureuser'

@secure()
@description('Windows administrator password for AKS Windows nodes. Override this for any real deployment.')
#disable-next-line secure-parameter-default
param windowsAdminPassword string = 'Password@4124567980'

@description('Retention period for the Log Analytics workspace.')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionDays int = 30

@description('Address space assigned to the custom virtual network hosting the AKS node pools.')
param aksVnetAddressSpace array = [
  '10.240.0.0/16'
]

@description('Subnet CIDR ranges for the AKS system node pool.')
param systemNodePoolSubnetAddressPrefixes array = [
  '10.240.0.0/22'
]

@description('Subnet CIDR ranges for the AKS Linux user node pool.')
param linuxUserNodePoolSubnetAddressPrefixes array = [
  '10.240.4.0/22'
]

@description('Subnet CIDR ranges for the AKS Windows user node pool.')
param windowsUserNodePoolSubnetAddressPrefixes array = [
  '10.240.8.0/22'
]

@description('Kubernetes service CIDR used by the AKS cluster.')
param aksServiceCidr string = '10.2.0.0/24'

@description('Cluster DNS service IP allocated from the service CIDR.')
param aksDnsServiceIp string = '10.2.0.10'

@description('Virtual machine size for the AKS system node pool.')
param systemNodePoolVmSize string = 'Standard_D2_v2'

@description('Set to true to create the dedicated Linux user node pool and subnet.')
param createLinuxUserNodePool bool = false

@description('Virtual machine size for the Linux user node pool.')
param linuxUserNodePoolVmSize string = 'Standard_DS2_v2'

@description('Set to true to create the dedicated Windows user node pool and subnet.')
param createWindowsUserNodePool bool = false

@description('Virtual machine size for the Windows user node pool.')
param windowsUserNodePoolVmSize string = 'Standard_D2_v2'

@description('Availability zones for the AKS system node pool.')
param systemNodePoolZones array = [
  '3'
]

@description('Availability zones for the AKS user node pools.')
param userNodePoolZones array = [
  '3'
]

var environmentSlug = toLower(environment)
var locationSlug = toLower(replace(location, ' ', ''))
var resourceGroupName = 'rg-${organizationName}-aks-${environmentSlug}-${locationSlug}'
var commonTags = union({
  environment: environment
  managed_by: 'bicep'
  owner: organizationName
  platform: 'aks'
  project: 'aks-bicep'
}, additionalTags)

resource aksResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

module aksPlatform './aks-platform.bicep' = {
  name: 'aks-platform-${environmentSlug}'
  scope: resourceGroup(aksResourceGroup.name)
  params: {
    location: location
    environment: environment
    organizationName: organizationName
    kubernetesVersion: kubernetesVersion
    additionalTags: additionalTags
    aksAdminGroupObjectId: aksAdminGroupObjectId
    aksAdminGroupDisplayName: aksAdminGroupDisplayName
    aksAdminGroupUniqueName: aksAdminGroupUniqueName
    sshPublicKeyData: sshPublicKeyData
    linuxAdminUsername: linuxAdminUsername
    windowsAdminUsername: windowsAdminUsername
    windowsAdminPassword: windowsAdminPassword
    logAnalyticsRetentionDays: logAnalyticsRetentionDays
    aksVnetAddressSpace: aksVnetAddressSpace
    systemNodePoolSubnetAddressPrefixes: systemNodePoolSubnetAddressPrefixes
    linuxUserNodePoolSubnetAddressPrefixes: linuxUserNodePoolSubnetAddressPrefixes
    windowsUserNodePoolSubnetAddressPrefixes: windowsUserNodePoolSubnetAddressPrefixes
    aksServiceCidr: aksServiceCidr
    aksDnsServiceIp: aksDnsServiceIp
    systemNodePoolVmSize: systemNodePoolVmSize
    createLinuxUserNodePool: createLinuxUserNodePool
    linuxUserNodePoolVmSize: linuxUserNodePoolVmSize
    createWindowsUserNodePool: createWindowsUserNodePool
    windowsUserNodePoolVmSize: windowsUserNodePoolVmSize
    systemNodePoolZones: systemNodePoolZones
    userNodePoolZones: userNodePoolZones
  }
}

output location string = aksPlatform.outputs.location
output resourceGroupId string = aksResourceGroup.id
output resourceGroupName string = aksResourceGroup.name
output clusterName string = aksPlatform.outputs.clusterName
output clusterId string = aksPlatform.outputs.clusterId
output virtualNetworkName string = aksPlatform.outputs.virtualNetworkName
output virtualNetworkId string = aksPlatform.outputs.virtualNetworkId
output configuredKubernetesVersion string = aksPlatform.outputs.configuredKubernetesVersion
output logAnalyticsWorkspaceId string = aksPlatform.outputs.logAnalyticsWorkspaceId
output logAnalyticsWorkspaceName string = aksPlatform.outputs.logAnalyticsWorkspaceName
output aksAdminGroupObjectId string = aksAdminGroupObjectId
output aksAdminGroupDisplayName string = aksAdminGroupDisplayName
output aksAdminGroupUniqueName string = aksAdminGroupUniqueName
output systemNodePoolSubnetId string = aksPlatform.outputs.systemNodePoolSubnetId
output linuxUserNodePoolSubnetId string = aksPlatform.outputs.linuxUserNodePoolSubnetId
output windowsUserNodePoolSubnetId string = aksPlatform.outputs.windowsUserNodePoolSubnetId
output linuxUserNodePoolId string = aksPlatform.outputs.linuxUserNodePoolId
output windowsUserNodePoolId string = aksPlatform.outputs.windowsUserNodePoolId

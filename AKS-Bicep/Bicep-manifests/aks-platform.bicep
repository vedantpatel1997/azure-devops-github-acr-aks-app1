targetScope = 'resourceGroup'

@description('Azure region where the AKS platform resources will be deployed.')
param location string

@description('Short environment name used in resource naming. Supported values are dev, qa, and prod.')
@allowed([
  'dev'
  'qa'
  'prod'
])
param environment string

@description('Short organization or team identifier used in resource naming.')
param organizationName string

@description('Pinned AKS Kubernetes version for the control plane and node pools.')
param kubernetesVersion string

@description('Additional Azure tags to merge with the template defaults.')
param additionalTags object = {}

@description('SSH public key data used for Linux node access.')
param sshPublicKeyData string

@description('Linux administrator username for AKS Linux nodes.')
param linuxAdminUsername string

@description('Windows administrator username for AKS Windows nodes.')
param windowsAdminUsername string

@secure()
@description('Windows administrator password for AKS Windows nodes.')
param windowsAdminPassword string

@description('Retention period for the Log Analytics workspace.')
param logAnalyticsRetentionDays int

@description('Address space assigned to the custom virtual network hosting the AKS node pools.')
param aksVnetAddressSpace array

@description('Subnet CIDR ranges for the AKS system node pool.')
param systemNodePoolSubnetAddressPrefixes array

@description('Subnet CIDR ranges for the AKS Linux user node pool.')
param linuxUserNodePoolSubnetAddressPrefixes array

@description('Subnet CIDR ranges for the AKS Windows user node pool.')
param windowsUserNodePoolSubnetAddressPrefixes array

@description('Kubernetes service CIDR used by the AKS cluster.')
param aksServiceCidr string

@description('Cluster DNS service IP allocated from the service CIDR.')
param aksDnsServiceIp string

@description('Virtual machine size for the AKS system node pool.')
param systemNodePoolVmSize string

@description('Set to true to create the dedicated Linux user node pool and subnet.')
param createLinuxUserNodePool bool

@description('Virtual machine size for the Linux user node pool.')
param linuxUserNodePoolVmSize string

@description('Set to true to create the dedicated Windows user node pool and subnet.')
param createWindowsUserNodePool bool

@description('Virtual machine size for the Windows user node pool.')
param windowsUserNodePoolVmSize string

@description('Availability zones for the AKS system node pool.')
param systemNodePoolZones array

@description('Availability zones for the AKS user node pools.')
param userNodePoolZones array

@description('Object ID of the Microsoft Entra group configured as the AKS admin group.')
param aksAdminGroupObjectId string

@description('Display name of the Microsoft Entra group configured as the AKS admin group.')
param aksAdminGroupDisplayName string

@description('Unique name of the Microsoft Entra group configured as the AKS admin group.')
param aksAdminGroupUniqueName string

var environmentSlug = toLower(environment)
var locationSlug = toLower(replace(location, ' ', ''))
var envNoDash = replace(environmentSlug, '-', '')
var nodePoolEnvironmentTag = length(envNoDash) >= 3 ? substring(envNoDash, 0, 3) : envNoDash
var windowsNodePoolTag = length(envNoDash) >= 2 ? substring(envNoDash, 0, 2) : envNoDash

var nameSuffix = '${organizationName}-aks-${environmentSlug}-${locationSlug}'
var clusterSuffix = '${organizationName}-${environmentSlug}-${locationSlug}'

var clusterName = 'aks-${clusterSuffix}'
var nodeResourceGroupName = 'rg-${nameSuffix}-nodes'
var logAnalyticsWorkspaceName = 'log-${nameSuffix}'
var virtualNetworkName = 'vnet-${nameSuffix}'
var systemSubnetName = 'snet-${nameSuffix}-system'
var linuxUserSubnetName = 'snet-${nameSuffix}-linux'
var windowsUserSubnetName = 'snet-${nameSuffix}-windows'
var systemNodePoolNameBase = 'sys${nodePoolEnvironmentTag}01'
var linuxUserNodePoolNameBase = 'lin${nodePoolEnvironmentTag}01'
var windowsUserNodePoolNameBase = 'win${windowsNodePoolTag}1'
var systemNodePoolName = substring(systemNodePoolNameBase, 0, min(length(systemNodePoolNameBase), 8))
var linuxUserNodePoolName = substring(linuxUserNodePoolNameBase, 0, min(length(linuxUserNodePoolNameBase), 8))
var windowsUserNodePoolName = substring(windowsUserNodePoolNameBase, 0, min(length(windowsUserNodePoolNameBase), 6))

var commonTags = union({
  environment: environment
  managed_by: 'bicep'
  owner: organizationName
  platform: 'aks'
  project: 'aks-bicep'
}, additionalTags)

var systemNodePoolLabels = {
  environment: environment
  'nodepool-os': 'linux'
  'nodepool-type': 'system'
  workload: 'system-apps'
}

var linuxUserNodePoolLabels = {
  environment: environment
  'nodepool-os': 'linux'
  'nodepool-type': 'user'
  workload: 'java-apps'
}

var windowsUserNodePoolLabels = {
  environment: environment
  'nodepool-os': 'windows'
  'nodepool-type': 'user'
  workload: 'dotnet-apps'
}

var systemNodePoolTags = union(commonTags, {
  node_pool: systemNodePoolName
  os: 'linux'
  role: 'system'
  workload: 'system-apps'
})

var linuxUserNodePoolTags = union(commonTags, {
  node_pool: linuxUserNodePoolName
  os: 'linux'
  role: 'user'
  workload: 'java-apps'
})

var windowsUserNodePoolTags = union(commonTags, {
  node_pool: windowsUserNodePoolName
  os: 'windows'
  role: 'user'
  workload: 'dotnet-apps'
})

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: commonTags
  properties: {
    features: {
      disableLocalAuth: false
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: logAnalyticsRetentionDays
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: commonTags
  properties: {
    addressSpace: {
      addressPrefixes: aksVnetAddressSpace
    }
  }
}

resource systemSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: virtualNetwork
  name: systemSubnetName
  properties: {
    addressPrefixes: systemNodePoolSubnetAddressPrefixes
  }
}

resource linuxUserSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = if (createLinuxUserNodePool) {
  parent: virtualNetwork
  name: linuxUserSubnetName
  properties: {
    addressPrefixes: linuxUserNodePoolSubnetAddressPrefixes
  }
}

resource windowsUserSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = if (createWindowsUserNodePool) {
  parent: virtualNetwork
  name: windowsUserSubnetName
  properties: {
    addressPrefixes: windowsUserNodePoolSubnetAddressPrefixes
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-10-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  tags: commonTags
  properties: {
    aadProfile: {
      adminGroupObjectIDs: [
        aksAdminGroupObjectId
      ]
      enableAzureRBAC: false
      managed: true
    }
    addonProfiles: {
      azurepolicy: {
        enabled: true
      }
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
          useAADAuth: 'true'
        }
        enabled: true
      }
    }
    agentPoolProfiles: [
      {
        availabilityZones: systemNodePoolZones
        count: 1
        enableAutoScaling: true
        maxCount: 3
        minCount: 1
        mode: 'System'
        name: systemNodePoolName
        nodeLabels: systemNodePoolLabels
        orchestratorVersion: kubernetesVersion
        tags: systemNodePoolTags
        type: 'VirtualMachineScaleSets'
        upgradeSettings: {
          drainTimeoutInMinutes: 5
          maxSurge: '10%'
          nodeSoakDurationInMinutes: 1
        }
        vmSize: systemNodePoolVmSize
        vnetSubnetID: systemSubnet.id
      }
    ]
    autoUpgradeProfile: {
      nodeOSUpgradeChannel: 'NodeImage'
    }
    dnsPrefix: clusterName
    enableRBAC: true
    kubernetesVersion: kubernetesVersion
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshPublicKeyData
          }
        ]
      }
    }
    networkProfile: {
      dnsServiceIP: aksDnsServiceIp
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      serviceCidr: aksServiceCidr
    }
    nodeResourceGroup: nodeResourceGroupName
    oidcIssuerProfile: {
      enabled: true
    }
    supportPlan: 'KubernetesOfficial'
    windowsProfile: createWindowsUserNodePool ? {
      adminPassword: windowsAdminPassword
      adminUsername: windowsAdminUsername
    } : null
  }
}

resource linuxUserNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-10-01' = if (createLinuxUserNodePool) {
  parent: aksCluster
  name: linuxUserNodePoolName
  properties: {
    availabilityZones: userNodePoolZones
    count: 1
    enableAutoScaling: true
    maxCount: 3
    minCount: 1
    mode: 'User'
    nodeLabels: linuxUserNodePoolLabels
    orchestratorVersion: kubernetesVersion
    osDiskSizeGB: 30
    osType: 'Linux'
    scaleSetPriority: 'Regular'
    tags: linuxUserNodePoolTags
    type: 'VirtualMachineScaleSets'
    upgradeSettings: {
      drainTimeoutInMinutes: 5
      maxSurge: '10%'
      nodeSoakDurationInMinutes: 1
    }
    vmSize: linuxUserNodePoolVmSize
    vnetSubnetID: linuxUserSubnet.id
  }
}

resource windowsUserNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-10-01' = if (createWindowsUserNodePool) {
  parent: aksCluster
  name: windowsUserNodePoolName
  properties: {
    availabilityZones: userNodePoolZones
    count: 1
    enableAutoScaling: true
    maxCount: 3
    minCount: 1
    mode: 'User'
    nodeLabels: windowsUserNodePoolLabels
    orchestratorVersion: kubernetesVersion
    osDiskSizeGB: 50
    osSKU: 'Windows2022'
    osType: 'Windows'
    scaleSetPriority: 'Regular'
    tags: windowsUserNodePoolTags
    type: 'VirtualMachineScaleSets'
    upgradeSettings: {
      drainTimeoutInMinutes: 5
      maxSurge: '10%'
      nodeSoakDurationInMinutes: 1
    }
    vmSize: windowsUserNodePoolVmSize
    vnetSubnetID: windowsUserSubnet.id
  }
}

output location string = location
output clusterName string = aksCluster.name
output clusterId string = aksCluster.id
output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output configuredKubernetesVersion string = kubernetesVersion
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output aksAdminGroupObjectId string = aksAdminGroupObjectId
output aksAdminGroupDisplayName string = aksAdminGroupDisplayName
output aksAdminGroupUniqueName string = aksAdminGroupUniqueName
output systemNodePoolSubnetId string = systemSubnet.id
output linuxUserNodePoolSubnetId string = createLinuxUserNodePool ? linuxUserSubnet.id : ''
output windowsUserNodePoolSubnetId string = createWindowsUserNodePool ? windowsUserSubnet.id : ''
output linuxUserNodePoolId string = createLinuxUserNodePool ? linuxUserNodePool.id : ''
output windowsUserNodePoolId string = createWindowsUserNodePool ? windowsUserNodePool.id : ''

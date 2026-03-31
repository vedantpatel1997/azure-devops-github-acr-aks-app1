targetScope = 'resourceGroup'

extension microsoftGraphV1

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

@description('Microsoft Entra user principal name to add to the AKS admin group.')
param aksAdminUserPrincipalName string

var environmentSlug = toLower(environment)
var locationSlug = toLower(replace(location, ' ', ''))
var clusterSuffix = '${organizationName}-${environmentSlug}-${locationSlug}'
var clusterName = 'aks-${clusterSuffix}'
var clusterAdminGroupDisplayName = 'grp-aksadmin-${clusterName}'
var clusterAdminGroupUniqueName = clusterAdminGroupDisplayName

resource clusterAdminUser 'Microsoft.Graph/users@v1.0' existing = {
  userPrincipalName: aksAdminUserPrincipalName
}

resource clusterAdmins 'Microsoft.Graph/groups@v1.0' = {
  description: 'Microsoft Entra group for AKS cluster administrators on ${clusterName}.'
  displayName: clusterAdminGroupDisplayName
  mailEnabled: false
  mailNickname: clusterAdminGroupDisplayName
  members: {
    relationships: [
      clusterAdminUser.id
    ]
  }
  securityEnabled: true
  uniqueName: clusterAdminGroupUniqueName
}

output aksAdminGroupObjectId string = clusterAdmins.id
output aksAdminGroupDisplayName string = clusterAdminGroupDisplayName
output aksAdminGroupUniqueName string = clusterAdminGroupUniqueName

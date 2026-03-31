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

@description('Additional Azure tags to merge with the template defaults.')
param additionalTags object = {}

@description('Microsoft Entra user principal name to add to the AKS admin group.')
param aksAdminUserPrincipalName string = 'admin@MngEnvMCAP797847.onmicrosoft.com'

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

module aksAdminGroup './entra-admin-group.bicep' = {
  name: 'aks-admin-group-${environmentSlug}'
  scope: resourceGroup(aksResourceGroup.name)
  params: {
    location: location
    environment: environment
    organizationName: organizationName
    aksAdminUserPrincipalName: aksAdminUserPrincipalName
  }
}

output resourceGroupId string = aksResourceGroup.id
output resourceGroupName string = aksResourceGroup.name
output aksAdminGroupObjectId string = aksAdminGroup.outputs.aksAdminGroupObjectId
output aksAdminGroupDisplayName string = aksAdminGroup.outputs.aksAdminGroupDisplayName
output aksAdminGroupUniqueName string = aksAdminGroup.outputs.aksAdminGroupUniqueName

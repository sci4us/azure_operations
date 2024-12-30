targetScope='subscription'

@description('Resource Group parameters for the Azure DevOps VMSS')
param resourceGroupName string = 'rg-platform' 

@description('Resource Group location for the Azure DevOps VMSS')
param resourceGroupLocation string = 'ukwest'


@description('The tags to be associated with the Operations deployment.')
var opsDeploymentTags = {
  deployment: 'bicep'
  environment: 'platform'
  application: 'azure-platform'
}

@description('The tags to be associated with the deployment.')
var appsAndDataDeploymentTags = {
  deployment: 'bicep'
  environment: 'platform'
  application: 'azure-apps-and-data'
}


// Creation of a new resource group for the Azure DevOps VMSS
resource newRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: opsDeploymentTags
}

// Creation of a new virtual network for Platform Operations
module operations_vnet 'sub_vnet.bicep' = {
  name: 'vnet-platform-ops'
  scope: newRG
  params: {
    vnetName : 'vnet-platform-ops'
    location: newRG.location
    vnetAddressPrefix: '192.168.0.0/16'
    vnetTags: opsDeploymentTags
  }
}

// Creation of a new virtual network for Sci4Us Applications
module application_vnet 'sub_vnet.bicep' = {
  name: 'vnet-apps-and-data'
  scope: newRG
  params: {
    vnetName: 'vnet-apps-and-data'
    location: newRG.location
    vnetAddressPrefix: '10.0.0.0/8'
    vnetTags: appsAndDataDeploymentTags
  }
}

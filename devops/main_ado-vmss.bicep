targetScope='subscription'

@description('Resource Group parameters for the Azure DevOps VMSS')
param resourceGroupName string = 'rg-ado-vmss' 

@description('Resource Group location for the Azure DevOps VMSS')
param resourceGroupLocation string = 'uksouth'

@secure()
@description('The admin password for the VMSS VMs.')
param vmssAdminPassword string


@description('The tags to be associated with the deployment.')
var deploymentTags = {
  deployment: 'bicep'
  environment: 'platform'
  application: 'azure-devops-vmss'
}

// Creation of a new resource group for the Azure DevOps VMSS
resource newRG 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: deploymentTags
}

// Creation of a new virtual network for the Azure DevOps VMSS
module vnet 'sub_ado-vmss_vnet.bicep' = {
  name: 'vnet'
  scope: newRG
  params: {
    location: newRG.location
    vnetAddressPrefix: '10.0.100.0/24'
    vnetTags: deploymentTags
  }
}

// Creation of a new virtual machine scale set for the Azure DevOps VMSS
module vmss 'sub_ado-vmss_vmss.bicep' = {
  name: 'vmss'
  scope: newRG
  params: {
    location: newRG.location
    subnetId: vnet.outputs.subnetId
    adminPassword: vmssAdminPassword
    vmssTags: deploymentTags
  }
}


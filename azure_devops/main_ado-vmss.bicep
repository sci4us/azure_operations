targetScope='subscription'

@description('Resource Group parameters for the Azure DevOps VMSS')
param resourceGroupName string = 'rg-platform-ado-vmss' 

@description('Resource Group location for the Azure DevOps VMSS')
param resourceGroupLocation string = 'ukwest'

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
module subnet 'sub_ado-vmss_subnet.bicep' = {
  name: 'subnet'
  scope: resourceGroup('rg-platform')
  params: {
    vnetName: 'vnet-platform-ops'
    newSubnetName: 'subnet-platforms-ops-ado-vmss'
    location: newRG.location
    subnetAddressPrefix: '192.168.100.0/24'
    subnetTags: deploymentTags
  }
}

// Creation of a new virtual machine scale set for the Azure DevOps VMSS
module vmss 'sub_ado-vmss_vmss.bicep' = {
  name: 'vmss'
  scope: newRG
  params: {
    location: newRG.location
    subnetId: subnet.outputs.subnetId
    adminPassword: vmssAdminPassword
    vmssTags: deploymentTags
  }
}

module managedIdentity 'sub_ado-managed-identity.bicep' = {
  name: 'managed-identity'
  scope: resourceGroup('rg-platform')
  params: {
    vmssPrincipalID: vmss.outputs.principalId
    vmssSecret: vmssAdminPassword
  }
}

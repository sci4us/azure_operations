@description('Location for virtual network resource')
param location string

@description('Virtual network address prefix, e.g. 10.0.0.0/28')
param vnetAddressPrefix string

@description('tags for the virtual network')
param vnetTags object

@description('tags for the virtual network')
param vnetName string

// Create of a new virtual network for the Azure DevOps VMSS, linked to the NSG
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: vnetTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: []
  }
}

// Outputs of the virtual network creation
output virtualNetwork object = vnet
output vnetResourceId string = vnet.id

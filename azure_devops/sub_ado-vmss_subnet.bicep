
@description('Location for virtual network resource')
param location string

@description('tags for the virtual network')
param subnetTags object

@description('Name of the VNET to add a subnet to')
param vnetName string

@description('Name of the subnet to add')
param newSubnetName string

@description('Address space of the subnet to add')
param subnetAddressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
   name: vnetName
}

// Create of a new network security group for the Azure DevOps VMSS
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-platform-ado-vmss'
  location: location
  tags: subnetTags
  properties: {
    securityRules: []
  }
}

// Create of a new subnet for the Azure DevOps VMSS, linked to the NSG
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' = {
  parent: vnet
  name: newSubnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}


// Outputs of the virtual network creation
output virtualNetwork object = vnet
output vnetResourceId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id

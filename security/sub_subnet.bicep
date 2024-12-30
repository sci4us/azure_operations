@description('Location for virtual network resource')
param location string

@description('name of the existing Virtual network')
param vnetName string

@description('tags for the virtual network')
param subnetTags object

@description('Name of the subnet to add')
param newSubnetName string

@description('Address space of the subnet to add')
param subnetAddressPrefix string


resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
}

// Create of a new network security group for the Azure DevOps VMSS
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-platform-security'
  location: location
  tags: subnetTags
  properties: {
    securityRules: []
  }
}

// Create of a new subnet for the Azure DevOps VMSS, linked to the NSG
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
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
output subnetId string = subnet.id


@description('Location for virtual network resource')
param location string

@description('Virtual network address prefix, e.g. 10.0.0.0/28')
param vnetAddressPrefix string

@description('tags for the virtual network')
param vnetTags object


// Create of a new network security group for the Azure DevOps VMSS
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-ado-vmss'
  location: location
  tags: vnetTags
  properties: {
    securityRules: [
      {
        // Rule to allow Azure DevOps inbound over SSH
        name: 'AllowADOInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          sourceAddressPrefixes: ['AzureDevOps']
          destinationAddressPrefixes: ['vnet-ado-vmss']
          description: 'Allow Azure DevOps inbound over SSH'
        }
      }
      {
        // Rule to allow Azure DevOps agent outbound over HTTPS
        name: 'AllowAzureDevopsAgentOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          priority: 200
          sourceAddressPrefixes: ['vnet-ado-vmss']
          destinationAddressPrefixes: ['AzureDevOps']
          description: 'Allow Azure DevOps agent outbound over HTTPS'
        }
      }
    ]
  }
}

// Create of a new virtual network for the Azure DevOps VMSS, linked to the NSG
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-ado-vmss'
  location: location
  tags: vnetTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: vnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// Outputs of the virtual network creation
output virtualNetwork object = vnet
output vnetResourceId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id

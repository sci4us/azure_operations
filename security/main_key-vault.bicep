targetScope = 'resourceGroup'

// Parameters

@description('Name of Key Vault')
param keyVaultName string = 'kv-platform-sci4us'

@description('Location for resources')
param location string = resourceGroup().location

@description('The tags to be associated with the Operations deployment.')
var kvDeploymentTags = {
  deployment: 'bicep'
  environment: 'platform'
  application: 'azure-platform'
}

@description('Name of the VNET to add a subnet to')
param vnetName string = 'vnet-platform-ops'

// DNS zone name for the vault service
var privateLink_dns_zone = 'privatelink.vaultcore.azure.net'

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
}

// Creation of a new virtual network for the Azure DevOps VMSS
module subnet 'sub_subnet.bicep' = {
  name: 'subnet'
  scope: resourceGroup()
  params: {
    vnetName: vnetName
    newSubnetName: 'subnet-platforms-ops-ado-vmss'
    location: resourceGroup().location
    subnetAddressPrefix: '192.168.100.0/24'
    subnetTags: kvDeploymentTags
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: keyVaultName
  location: location
  tags: kvDeploymentTags
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 30
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      virtualNetworkRules: []
    }
    publicNetworkAccess: 'Disabled'
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource privateDNS 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateLink_dns_zone
  location: 'global'
  tags: kvDeploymentTags
}

resource privateDNSLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDNS.name}-link'
  location: 'global'
  tags: kvDeploymentTags
  parent: privateDNS
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${keyvault.name}-pivateendpoint'
  location: location
  tags: kvDeploymentTags
  properties: {
    subnet: {
      id: subnet.outputs.subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${keyvault.name}-serviceconnection'
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource pdnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  name: '${keyvault.name}-dnszonegroup'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDNS.id
        }
      }
    ]
  }
}

// ============================================================================
// Outputs

output vault object = keyvault

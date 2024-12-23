
@description('Location for virtual machine scale set and virtual machines')
param location string

// VM parameters

@description('The SKU of the VM')
param vmSku string = 'Standard_B2s'

@description('The ID of the subnet where the VMSS will be located')
param subnetId string

@description('The admin username for the VM.')
param adminUsername string = 'admin'

@secure()
@description('The admin password for the VM.')
param adminPassword string


// VMSS parameters
 
@description('The number of VM instances')
param vmssInstanceCount int = 1

@description('tags for the virtual network')
param vmssTags object

@description('The prefix for the VMSS name')
var vmssName = 'ado-vmss'


// Variables for the new VM setup and VMSS setup

var operatingSystem = {
  computerNamePrefix: vmssName
  adminUsername: adminUsername
  adminPassword: adminPassword
}

var vmImage = {
  publisher: 'Canonical'
  offer: 'Ubuntu'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

var networkConfig = {
  networkInterfaceConfigurations: [
    {
      name: 'vmNIC'
      properties: {
        primary: true
        ipConfigurations: [
          {
            name: 'ipconfig'
            properties: {
              subnet: {
                id: subnetId
              }
            }
          }
        ]
      }
    }
  ]
}

var osDiskConfig = {
  caching: 'ReadWrite'
  managedDisk: {
    storageAccountType: 'Standard_LRS'
  }
  createOption: 'FromImage'
}

var storageProfile = {
  imageReference: vmImage
  osDisk: osDiskConfig
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: vmssName
  location: location
  tags: vmssTags
  sku: {
    name: vmSku
    tier: 'Standard'
    capacity: vmssInstanceCount
  }
  properties: {
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: storageProfile
      osProfile: operatingSystem
      networkProfile: networkConfig
    }
  }
}


// Outputs of the VMSS creation
output vmssId string = vmss.id
output vmssName string = vmss.name
output vmssLocation string = vmss.location
output principalId string = vmss.identity.principalId

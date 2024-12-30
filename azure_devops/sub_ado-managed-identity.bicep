@description('Virtual Machine Scale Set Principal ID of Service Principal')
param vmssPrincipalID string

@secure()
@description('The password for the VMSS VMs.')
param vmssSecret string

// Built-in roleDefinition GUID for kay vault secrets user
var roleDefinition_keyVaultSecretsOfficer = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

// Get the key vault resource
resource keyvault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: 'kv-platform-sci4us'
}

// Assign the role to the VMSS principal
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('${vmssPrincipalID}${keyvault.id}${roleDefinition_keyVaultSecretsOfficer}')
  scope: keyvault
  properties: {
    principalId: vmssPrincipalID
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions',roleDefinition_keyVaultSecretsOfficer)
  }
}

// Add VMSS Password to the key vault
resource secret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyvault
  name: 'ADO-VMSS-VM-Password'
  properties: {
    value: vmssSecret
  }
}

targetScope = 'subscription'

param PrinicpalId string
param RoleDefinitionId string
param Scope string

resource RBACFunctionAppMSIhasVritualDesktopVMContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(Scope,PrinicpalId,RoleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', RoleDefinitionId)
    principalId: PrinicpalId
  }
}

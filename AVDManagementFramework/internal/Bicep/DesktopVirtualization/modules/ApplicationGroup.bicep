param ApplicationGroupName string
param Location string
param HostPoolId string
param ApplicationGroupType string
param FriendlyName string
param Tags object = {}
param RoleDefinitionId string = '1d18fff3-a72a-46b5-b4a9-0b38a3cd7e63'
param PrincipalId array
param SessionHostJoinType string

//Variables
var AADVVMUserLoginRoleId = 'fb879df8-f326-4884-b1cf-06f3ad86be52'

resource ApplicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-02-01-preview' = {
  name: ApplicationGroupName
  location: Location
  properties:{
    hostPoolArmPath: HostPoolId
    applicationGroupType: ApplicationGroupType
    friendlyName: FriendlyName
  }
  tags: Tags
}

resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = [for item in PrincipalId:{
  name: guid(item,ApplicationGroup.id)
  scope: ApplicationGroup
  properties:{
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', RoleDefinitionId)
    principalId: item
  }
}]

// Assign Virtual Machine User Login if using AAD // TODO: Do we do this per session? Add Option for Administrator?
resource AADVMLogin 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (item, index) in PrincipalId: if (SessionHostJoinType == 'AAD') {
  name:guid(item,resourceGroup().id)
  scope:resourceGroup()
  properties:{
    roleDefinitionId:resourceId('Microsoft.Authorization/roleDefinitions',AADVVMUserLoginRoleId)
    principalId:item
  }
}]

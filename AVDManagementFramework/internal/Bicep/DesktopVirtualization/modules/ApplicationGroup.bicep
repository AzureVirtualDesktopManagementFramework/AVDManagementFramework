param ApplicationGroupName string
param Location string
param HostPoolId string
param FriendlyName string
param Tags object = {}
param RoleDefinitionId string = '1d18fff3-a72a-46b5-b4a9-0b38a3cd7e63'
param PrincipalId array

resource ApplicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-02-01-preview' = {
  name: ApplicationGroupName
  location: Location
  properties:{
    hostPoolArmPath: HostPoolId
    applicationGroupType: 'Desktop' //TODO: Add this as a configuration
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

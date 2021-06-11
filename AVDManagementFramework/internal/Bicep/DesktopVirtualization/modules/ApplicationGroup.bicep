param ApplicationGroupName string
param Location string
param HostPoolId string
param Tags object = {}

resource ApplicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-02-01-preview' = {
  name: ApplicationGroupName
  location: Location
  properties:{
    hostPoolArmPath: HostPoolId
    applicationGroupType: 'Desktop' //TODO: Add this as a configuration
  }
  tags: Tags
}

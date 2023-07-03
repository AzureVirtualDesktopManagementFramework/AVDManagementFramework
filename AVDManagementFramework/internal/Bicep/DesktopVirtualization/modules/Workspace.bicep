param WorkspaceName string
param Location string
param ApplicationGroupReferences array
param FriendlyName string
param Tags object = {}

resource Workspace 'Microsoft.DesktopVirtualization/workspaces@2021-02-01-preview' = {
  name: WorkspaceName
  location: Location
  properties:{
    applicationGroupReferences: ApplicationGroupReferences
    friendlyName: FriendlyName
  }
  tags: Tags
}

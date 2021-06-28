param WorkspaceName string
param Location string
param ApplicationGroupReferences array
param Tags object = {}

resource Workspace 'Microsoft.DesktopVirtualization/workspaces@2021-02-01-preview' = {
  name: WorkspaceName
  location: Location
  properties:{
    applicationGroupReferences: ApplicationGroupReferences
  }
  tags: Tags
}

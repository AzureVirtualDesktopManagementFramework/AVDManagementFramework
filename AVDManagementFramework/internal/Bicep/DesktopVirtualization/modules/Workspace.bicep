param WorkspaceName string
param Location string
param ApplicationGroupReferences array

resource Workspace 'Microsoft.DesktopVirtualization/workspaces@2021-02-01-preview' = {
  name: WorkspaceName
  location: resourceGroup().location
  properties:{
    applicationGroupReferences: ApplicationGroupReferences
  }
}

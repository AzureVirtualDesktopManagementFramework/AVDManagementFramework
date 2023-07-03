param Location string = resourceGroup().location
param Workspaces array

module workspaceModule 'modules/Workspace.bicep' = [for workspaceitem in Workspaces:{
  name: workspaceitem.name
  params:{
    WorkspaceName:workspaceitem.name
    ApplicationGroupReferences:workspaceitem.ApplicationGroupReferences
    Location: Location
    FriendlyName: workspaceitem.FriendlyName
    Tags: workspaceitem.Tags
  }
}]

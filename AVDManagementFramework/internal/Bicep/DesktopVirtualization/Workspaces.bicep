param Workspaces array

module workspaceModule 'modules/Workspace.bicep' = [for workspaceitem in Workspaces:{
  name: workspaceitem.name
  params:{
    WorkspaceName:workspaceitem.name
    ApplicationGroupReferences:workspaceitem.ApplicationGroupReferences
    Location: resourceGroup().location
    Tags: workspaceitem.Tags
  }
}]

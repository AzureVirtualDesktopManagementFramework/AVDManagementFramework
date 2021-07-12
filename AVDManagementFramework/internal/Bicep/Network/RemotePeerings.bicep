param RemotePeerings array

module RemotePeering 'modules/RemotePeering.bicep' = [for item in RemotePeerings: {
  name: item.Name
  params: {
    Name: item.Name
    LocalVNetResourceId: item.LocalVNetResourceId
    RemoteVNetName: item.RemoteVNetName
  }
  scope: resourceGroup(item.ResourceGroupName)
}]

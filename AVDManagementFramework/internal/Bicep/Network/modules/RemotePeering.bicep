param Name string
param LocalVNetResourceId string
param RemoteVNetName string



resource RemotePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  name: '${RemoteVNetName}/${Name}'
  properties: {
    remoteVirtualNetwork: {
      id: LocalVNetResourceId
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
  }

}

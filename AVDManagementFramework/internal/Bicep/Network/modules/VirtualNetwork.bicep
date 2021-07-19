param VirtualNetworkName string
param Location string
param AddressSpace string
param DNSServers array
param Subnets array
param VirtualNetworkPeerings array
param Tags object = {}

resource VirtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: VirtualNetworkName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        AddressSpace
      ]
    }
    dhcpOptions: {
      dnsServers: DNSServers
    }
    subnets: [for subnet in Subnets: {
      //TODO: Account for subnets belonging to different vnets
      name: subnet.Name

     properties: subnet.properties
    }]
  }
  tags: Tags
}

resource Peerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = [for peering in VirtualNetworkPeerings: {
  name: '${VirtualNetworkName}/${peering.name}'
  properties: {
    remoteVirtualNetwork: {
      id: peering.RemoteNetworkID
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    useRemoteGateways: peering.useRemoteGateways
  }
  dependsOn:[
    VirtualNetwork
  ]
}]

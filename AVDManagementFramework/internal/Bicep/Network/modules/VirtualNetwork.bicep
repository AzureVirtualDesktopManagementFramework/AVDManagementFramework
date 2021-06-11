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
      properties: (subnet.NSGID != ''? { // Conditional deployment if NSG is defined only.
        addressPrefix: subnet.AddressPrefix
        privateEndpointNetworkPolicies: (subnet.PrivateLink ? 'Disabled' : 'Enabled')
        networkSecurityGroup: {
          id: subnet.NSGId
        }
      }: {
        addressPrefix: subnet.AddressPrefix
        privateEndpointNetworkPolicies: (subnet.PrivateLink ? 'Disabled' : 'Enabled')
      })
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
    useRemoteGateways: true
  }
  dependsOn:[
    VirtualNetwork
  ]
}]

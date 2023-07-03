param SubnetName string
param VirtualNetworkName string
param AddressPrefix string
param PrivateLink bool
param NSGId string
param RouteTableID string

resource Subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' =  {
  name: '${VirtualNetworkName}/${SubnetName}'
  properties:{
    addressPrefix: AddressPrefix
    privateEndpointNetworkPolicies: ( PrivateLink ? 'Disabled' : 'Enabled' )
    networkSecurityGroup: {
      id: NSGId
    }
    routeTable: {
      id: RouteTableID
    }
  }
}

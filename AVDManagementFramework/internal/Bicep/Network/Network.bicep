param VirtualNetworks array
param Subnets array
param NetworkSecurityGroups array
param RouteTables array

module NetworkSecurityGroupModule 'modules/NetworkSecurityGroup.bicep' = [for nsgitem in NetworkSecurityGroups:{
  name: nsgitem.resourcename
  params:{
    NSGName: nsgitem.resourcename
    location: resourceGroup().location
    securityRules: nsgitem.SecurityRules
    Tags: nsgitem.Tags
  }
}]
module RouteTableModule 'modules/RouteTable.bicep' = [for routetableitem in RouteTables:{
  name: routetableitem.ResourceName
  params: {
    Name: routetableitem.ResourceName
    Location: resourceGroup().location
    routes: routetableitem.Routes
    disableBgpRoutePropagation: routetableitem.DisableBgpRoutePropagation
    Tags: routetableitem.Tags
  }
}]
module VirtualNetworkModule './modules/VirtualNetwork.bicep' = [for vnetitem in VirtualNetworks: {
  name: vnetitem.Name
  params:{
    VirtualNetworkName: vnetitem.ResourceName
    Location: resourceGroup().location
    AddressSpace: vnetitem.AddressSpace
    DNSServers: vnetitem.DNSServers
    Subnets: Subnets
    VirtualNetworkPeerings: vnetitem.VirtualNetworkPeerings
    Tags: vnetitem.Tags
  }
  dependsOn:[
    NetworkSecurityGroupModule
    RouteTableModule
  ]
}]

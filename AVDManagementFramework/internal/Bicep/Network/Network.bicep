param VirtualNetworks array
param Subnets array
param NetworkSecurityGroups array

module NetworkSecurityGroupModule 'modules/NetworkSecurityGroup.bicep' = [for nsgitem in NetworkSecurityGroups:{
  name: nsgitem.resourcename
  params:{
    NSGName: nsgitem.resourcename
    location: resourceGroup().location
    securityRules: nsgitem.SecurityRules
    Tags: nsgitem.Tags
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
  dependsOn: NetworkSecurityGroupModule
}]

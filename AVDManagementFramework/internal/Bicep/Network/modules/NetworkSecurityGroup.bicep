param NSGName string
param location string
param securityRules array
param Tags object = {}

resource NSG 'Microsoft.Network/networkSecurityGroups@2020-11-01' ={
  name: NSGName
  location: location
  properties:{
    securityRules: [for rule in securityRules:{
      name: rule.Name
      properties:{
        description: rule.name
        direction: rule.direction
        access: rule.access
        priority: rule.priority
        sourceAddressPrefix: rule.source
        sourcePortRange: rule.SourcePort
        destinationAddressPrefix: rule.destination
        destinationPortRange: rule.DestinationPort
        protocol: rule.protocol
      }
    }]
  }
  tags: Tags
}

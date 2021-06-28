param PrivateLinkName string
param Location string
param SubnetID string
param StorageAccountID string
param Tags object = {}

resource PrivateLink 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: PrivateLinkName
  location: Location
  properties: {
    subnet: {
      id: SubnetID
    }
  privateLinkServiceConnections:[
    {
      name: PrivateLinkName
      properties: {
        privateLinkServiceId: StorageAccountID
        groupIds: [
          'file'
        ]
      }
    }
  ]
  }
  tags: Tags
}

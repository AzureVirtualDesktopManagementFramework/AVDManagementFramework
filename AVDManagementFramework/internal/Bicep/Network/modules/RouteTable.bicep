param Name string
param Location string
param routes array
param disableBgpRoutePropagation bool = false
param Tags object = {}

resource RouteTable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: Name
  location: Location
  properties:{
    routes: routes
    disableBgpRoutePropagation: disableBgpRoutePropagation
  }
  tags: Tags
}

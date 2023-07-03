param ApplicationGroupName string
param RemoteAppName string
param RemoteAppProperties object

resource RemoteApp 'Microsoft.DesktopVirtualization/applicationGroups/applications@2021-07-12' = {
  name: '${ApplicationGroupName}/${RemoteAppName}'
  properties: RemoteAppProperties
}

param HostPoolName string
param Location string
param PoolType string
param maxSessionLimit int
param Tags object = {}
param SessionHostJoinType string = 'AD'

param CustomRdpProperty string = 'autoreconnectionenabled:i:1;camerastoredirect:s:;devicestoredirect:s:;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:0;redirectlocation:i:0;redirectprinters:i:0;redirectsmartcards:i:0;redirectwebauthn:i:0;usbdevicestoredirect:s:'
param StartVMOnConnect bool



param TokenExpirationTime string = dateTimeAdd(utcNow('O'),'PT2H','O')

var loadBalancerType = (PoolType == 'Personal') ? 'Persistent' : 'BreadthFirst'
var hostPoolType = (PoolType == 'Personal') ? 'Personal' : 'Pooled'


resource HostPool 'Microsoft.DesktopVirtualization/hostPools@2022-09-09' = {
  name: HostPoolName
  location: Location
  properties: {
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: 'Desktop'
    maxSessionLimit: maxSessionLimit
    validationEnvironment: false // TODO: Decide on validation environment from stage
    registrationInfo: {
      registrationTokenOperation: 'Update'
      expirationTime: TokenExpirationTime
    }
    customRdpProperty: (SessionHostJoinType == 'AAD') ?   'targetisaadjoined:i:1;enablerdsaadauth:i:1;${CustomRdpProperty}' : CustomRdpProperty
    startVMOnConnect: StartVMOnConnect
  }
  tags:Tags
}

//output registrationToken string = HostPool.properties.registrationInfo.token //TODO: Delete this line


param Location string = resourceGroup().location
param HostPools array
param ApplicationGroups array
param SessionHosts array

//TODO: There is only one session host per RG, do we really need the complexity of an array loop here?
module hostPoolModule 'modules/HostPool.bicep' = [for hostpoolitem in HostPools:{
  name: hostpoolitem.name
  params:{
    HostPoolName: hostpoolitem.name
    Location: Location
    PoolType: hostpoolitem.PoolType
    maxSessionLimit: hostpoolitem.MaxSessionLimit
    Tags: hostpoolitem.Tags
  }
}]
module applicationGroupModule 'modules/ApplicationGroup.bicep' = [for applicationGroupItem in ApplicationGroups:{
  name: applicationGroupItem.name
  params:{
    ApplicationGroupName: applicationGroupItem.name
    Location: Location
    HostPoolId: applicationGroupItem.HostPoolId
    FriendlyName: applicationGroupItem.FriendlyName
    Tags: applicationGroupItem.Tags
    PrincipalId: applicationGroupItem.PrincipalId
  }
  dependsOn: hostPoolModule
}]
module SessionHostsModule 'modules/sessionHost.bicep' = [for sessionHostItem in SessionHosts:{
  name: sessionHostItem.name
  params:{
    VMName: sessionHostItem.name
    Location: Location
    AdminUsername: sessionHostItem.AdminUsername
    AdminPassword: sessionHostItem.AdminPassword
    SubnetID: sessionHostItem.SubnetID
    TimeZone: sessionHostItem.TimeZone
    VMSize: sessionHostItem.VMSize
    imageReference: sessionHostItem.ImageReference
    Tags: sessionHostItem.Tags

    // Add as session host
    HostPoolName:  hostPoolModule[0].name
    HostPoolToken: hostPoolModule[0].outputs.registrationToken //We only have one host pool per deployment, we are using arrays for consistency.
    WVDArtifactsURL: sessionHostItem.WVDArtifactsURL

    // Join Domain
    DomainName: sessionHostItem.DomainName
    OUPath: sessionHostItem.OUPath
    DomainJoinUserName: sessionHostItem.DomainJoinUserName
    DomainJoinPassword: sessionHostItem.DomainJoinPassword
  }
}]

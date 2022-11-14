param Location string = resourceGroup().location
param HostPools array
param ApplicationGroups array
param SessionHosts array
param RemoteApps array

//TODO: There is only one session host per RG, do we really need the complexity of an array loop here?
module hostPoolModule 'modules/HostPool.bicep' = [for hostpoolitem in HostPools: {
  name: hostpoolitem.name
  params: {
    HostPoolName: hostpoolitem.name
    Location: Location
    PoolType: hostpoolitem.PoolType
    maxSessionLimit: hostpoolitem.MaxSessionLimit
    SessionHostJoinType: hostpoolitem.SessionHostJoinType
    Tags: hostpoolitem.Tags
  }
}]
module applicationGroupModule 'modules/ApplicationGroup.bicep' = [for applicationGroupItem in ApplicationGroups: {
  name: applicationGroupItem.name
  params: {
    ApplicationGroupName: applicationGroupItem.name
    ApplicationGroupType: applicationGroupItem.ApplicationGroupType
    Location: Location
    HostPoolId: applicationGroupItem.HostPoolId
    FriendlyName: applicationGroupItem.FriendlyName
    Tags: applicationGroupItem.Tags
    PrincipalId: applicationGroupItem.PrincipalId
    SessionHostJoinType: applicationGroupItem.SessionHostJoinType
  }
  dependsOn: hostPoolModule
}]

module RemoteAppModule 'modules/RemoteApp.bicep' = [for (remoteAppItem, i) in RemoteApps: {
  name: 'RemoteApp_${i+1}_${replace(replace(remoteAppItem.RemoteAppName,'/','_'),' ','')}'
  params: {
    ApplicationGroupName: remoteAppItem.ApplicationGroupName
    RemoteAppName: remoteAppItem.RemoteAppName
    RemoteAppProperties: remoteAppItem.RemoteAppProperties
  }
  dependsOn: [
    applicationGroupModule
    SessionHostsModule
  ]
}]
module SessionHostsModule 'modules/sessionHost.bicep' = [for sessionHostItem in SessionHosts: {
  name: sessionHostItem.name
  params: {
    VMName: sessionHostItem.name
    Location: Location
    AdminUsername: sessionHostItem.AdminUsername
    AdminPassword: sessionHostItem.AdminPassword
    SubnetID: sessionHostItem.SubnetID
    TimeZone: sessionHostItem.TimeZone
    VMSize: sessionHostItem.VMSize
    PreJoinRunCommand: sessionHostItem.PreJoinRunCommand
    imageReference: sessionHostItem.ImageReference
    AvailabilityZone: sessionHostItem.AvailabilityZone
    AcceleratedNetworking: sessionHostItem.AcceleratedNetworking
    Tags: sessionHostItem.Tags

    // Add as session host
    HostPoolName: hostPoolModule[0].name
    HostPoolToken: hostPoolModule[0].outputs.registrationToken //We only have one host pool per deployment, we are using arrays for consistency.
    WVDArtifactsURL: sessionHostItem.WVDArtifactsURL


    // Join Domain
    JoinObject: (sessionHostItem.SessionHostJoinType == 'ADDS') ? {
      SessionHostJoinType:  sessionHostItem.SessionHostJoinType
    } : {
      SessionHostJoinType:  sessionHostItem.SessionHostJoinType //This broken, needs review (Join Object?)
      //DomainName: sessionHostItem.DomainName
      //OUPath: sessionHostItem.OUPath
      //DomainJoinUserName: sessionHostItem.DomainJoinUserName
      //DomainJoinPassword: sessionHostItem.DomainJoinPassword // TODO: Password is not secure like that
    }
  }
}]

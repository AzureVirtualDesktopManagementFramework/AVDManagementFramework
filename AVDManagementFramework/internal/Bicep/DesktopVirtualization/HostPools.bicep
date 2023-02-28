targetScope = 'subscription'

param Location string
param HostPools array
param ApplicationGroups array
//param SessionHosts array // TODO: Delete This
param RemoteApps array
param ReplacementPlan object
param ResourceGroupName string

//TODO: There is only one session host per RG, do we really need the complexity of an array loop here?
module hostPoolModule 'modules/HostPool.bicep' = [for hostpoolitem in HostPools: {
  scope: resourceGroup(ResourceGroupName)
  name: hostpoolitem.name
  params: {
    HostPoolName: hostpoolitem.name
    Location: Location
    PoolType: hostpoolitem.PoolType
    maxSessionLimit: hostpoolitem.MaxSessionLimit
    SessionHostJoinType: hostpoolitem.SessionHostJoinType
    Tags: hostpoolitem.Tags
    CustomRdpProperty: hostpoolitem.CustomRdpProperty
  }
}]
module applicationGroupModule 'modules/ApplicationGroup.bicep' = [for applicationGroupItem in ApplicationGroups: {
  scope: resourceGroup(ResourceGroupName)
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
  scope: resourceGroup(ResourceGroupName)
  name: 'RemoteApp_${i + 1}_${replace(replace(remoteAppItem.RemoteAppName, '/', '_'), ' ', '')}'
  params: {
    ApplicationGroupName: remoteAppItem.ApplicationGroupName
    RemoteAppName: remoteAppItem.RemoteAppName
    RemoteAppProperties: remoteAppItem.RemoteAppProperties
  }
  dependsOn: [
    applicationGroupModule
    //SessionHostsModule // TODO: Check if all is well after removing this
  ]
}]

module ReplacementPlanModule 'modules/ReplacementPlan.bicep' = {
  scope: resourceGroup(ResourceGroupName)
  name: 'ReplacementPlan_${replace(replace(ReplacementPlan.Name, '/', '_'), ' ', '')}'
  params: {
    Location: Location
    //Storage Account
    StorageAccountName: 'safuncshr${uniqueString(ReplacementPlan.Name)}'

    // Log Analytics Workspace
    LogAnalyticsWorkspaceName: '${ReplacementPlan.Name}-LAW-01'

    //FunctionApp
    FunctionAppName: ReplacementPlan.Name
    HostPoolResourceGroupName: ResourceGroupName
    HostPoolName: ReplacementPlan.HostPoolName
    TagIncludeInAutomation: ReplacementPlan.TagIncludeInAutomation
    TagDeployTimestamp: ReplacementPlan.TagDeployTimestamp
    TagPendingDrainTimestamp: ReplacementPlan.TagPendingDrainTimestamp
    TargetVMAgeDays: ReplacementPlan.TargetVMAgeDays
    DrainGracePeriodHours: ReplacementPlan.DrainGracePeriodHours
    FixSessionHostTags: ReplacementPlan.FixSessionHostTags
    SHRDeploymentPrefix: ReplacementPlan.SHRDeploymentPrefix
    TargetSessionHostCount: ReplacementPlan.NumberOfSessionHosts
    MaxSimultaneousDeployments: ReplacementPlan.MaxSimultaneousDeployments
    SessionHostNamePrefix: ReplacementPlan.SessionHostNamePrefix
    FunctionAppZipUrl: ReplacementPlan.AVDReplacementPlanURL
    ADOrganizationalUnitPath: ReplacementPlan.ADOrganizationalUnitPath
    SessionHostTemplateUri: ReplacementPlan.SessionHostTemplateUri
    //SessionHostTemplateParametersPS1Uri: ReplacementPlan.SessionHostTemplateParametersPS1Uri
    SessionHostParameters: ReplacementPlan.SessionHostParameters
    SubnetId: ReplacementPlan.SubnetId
    SubscriptionId: subscription().subscriptionId
    SessionHostInstanceNumberPadding: ReplacementPlan.SessionHostInstanceNumberPadding
    ReplaceSessionHostOnNewImageVersion: ReplacementPlan.ReplaceSessionHostOnNewImageVersion
    ReplaceSessionHostOnNewImageVersionDelayDays: ReplacementPlan.ReplaceSessionHostOnNewImageVersionDelayDays
  }
  dependsOn: hostPoolModule
}

module RBACFunctionApphasDesktopVirtualizationVirtualMachineContributor 'modules/RBACRoleAssignment.bicep' = {
  name: 'RBACFunctionApphasDesktopVirtualizationVirtualMachineContributor'
  params: {
    PrinicpalId: ReplacementPlanModule.outputs.FunctionAppSP
    RoleDefinitionId: 'a959dbd1-f747-45e3-8ba6-dd80f235f97c' // Desktop Virtualization Virtual Machine Contributor
    Scope: subscription().id //We assign the permission at the subscription level to be able to attach the vnic to a subnet in a different resource group.
  }
  dependsOn: [ ReplacementPlanModule ]
}

/* //TODO: Delete this
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
*/

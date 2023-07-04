//------ Parameters ------//
param Name string
param Location string = resourceGroup().location
param Timezone string
param Schedules array
param ExclusionTag string
param HostPoolId string
param Tags object = {}

//------ Variables ------//

//------ Resources ------//
resource deployScalingPlan 'Microsoft.DesktopVirtualization/scalingPlans@2022-09-09' = {
  name: Name
  location: Location
  properties: {
    friendlyName: Name
    timeZone: Timezone
    schedules: Schedules
    exclusionTag: ExclusionTag
    hostPoolReferences: [
      {
        hostPoolArmPath: HostPoolId
        scalingPlanEnabled: true
      }
    ]
    hostPoolType: 'Pooled'
  }

  tags: Tags
}
//------ Outputs ------//

# AVD Management Framework
## Change History
  - **AVDMF v1.0.82 (Configuration v1.1.1)**:
    - Fixes:
      - Fixes parameter name in New-AVDMFConfiguration
      - Fixed default route in Sample Configuration
  - **AVDMF v1.0.80 (Configuration v1.1.1)**:
    - Breaking Change
      - Upgraded to the latest version of AVD Replacement Plans
      - We now use TemplateSpecs to for the Replacement Plan Template.
      - You can add bicep templates under .\DesktopVirtualization\VMTemplates\TemplateFiles
      - Use a `New-AVDMFConfiguration` to create a new configuration folder with sample files.
    - New:
      - New command `New-AVDMFConfiguration` to create a new configuration folder with sample files.
      - `Set-AVDMFConfiguration` now accepts a new switch parameter `-Offline`. This can be used for testing only and will not attempt to resolve any Ids.
      - Added support for Location as a naming component.
        - Just add a new component `LocationAbv` to your naming styles, and provide the desired abbreviations in the component file.
    - Fixes:
      - Improved debug logging and errors for name generator.
      - Fixed a bug when generating storage name for AVD ReplacementPlan
      - Changed the name of the Log Analytics Workspace for AVD ReplacementPlan to LAW-AVDReplacementPlan. In a future release this will be configurable so you can use a pre-existing workspace.
      - Change the name of the Application Service Plan to asp-AVDReplacementPlan. In a future release this will be configurable so you can set a naming convention.
  - **AVDMF v1.0.74 (Configuration v1.0.58)**:
    - New:
      - File Share Auto Grow Logic App
        - Now you can deploy a Logic App to each storage account that will automatically grow the file share keeping a minimum buffer.
        - Configure this in the Storage Account configuration under `Storage > StorageAccounts`
          ```diff
          {
              "ReferenceName" : "ProfileSA01",
              "AccessLevel": "All",
              "HostPoolType": "All",
              "accountType": "Premium_LRS",
              "kind": "FileStorage",
              "shareSoftDeleteRetentionDays": 7,
          +    "FileShareAutoGrow":{
          +        "Enabled": true,
          +        "TargetFreeSpaceGB": 50,
          +    }   "AllowShrink": true
              },
              "DirectoryServiceOptions": "AADKerb",
              "DomainName": "contoso.com",
              "DomainGuid": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
              "DefaultSharePermission" : "StorageFileDataSmbShareContributor"
          }
          ```
  - **AVDMF v1.0.72 (Configuration v1.0.58)**:
    - New:
      - Support for Scaling Plans and Start VM On Connect
        - Now you can deploy a scaling plan and Start VM On Connect as part of the host pool deployment.
        - This will also configure permissions for Azure Virtual Desktop Service Principal over the subscription.
        - Configure Scaling Plan Templates under `DesktopVirtualization > ScalingPlanTemplates`
          ```JSON
          {
              "ReferenceName": "ScalingPlan01",
              "timeZone": "Arabian Standard Time",
              "Schedules": [
                  "WeekdaySchedule",
                  "WeekendSchedule"
              ],
              "ExclusionTag": "ScalingPlanExclusion",
              "Tags": {}
          }
          ```
        - Configure Schedules under `DesktopVirtualization > ScalingPlanScheduleTemplates`
          ```JSON
          {
              "ReferenceName": "WeekendSchedule",
              "Parameters": {
                  "name": "WeekendSchedule",
                  "daysOfWeek": [
                      "Friday",
                      "Saturday"
                  ],
                  // RAMP UP //
                  "rampUpStartTime": {
                      "hour": 9,
                      "minute": 0
                  },
                  "rampUpCapacityThresholdPct": 90,
                  "rampUpLoadBalancingAlgorithm": "DepthFirst",
                  "rampUpMinimumHostsPct": 0,

                  // PEAK //
                  "peakStartTime": {
                      "hour": 10,
                      "minute": 0
                  },
                  "peakLoadBalancingAlgorithm": "DepthFirst",

                  // RAMP DOWN //
                  "rampDownStartTime": {
                      "hour": 16,
                      "minute": 0
                  },
                  "rampDownCapacityThresholdPct": 90,
                  "rampDownForceLogoffUsers": true,
                  "rampDownLoadBalancingAlgorithm": "DepthFirst",
                  "rampDownMinimumHostsPct": 0,
                  "rampDownNotificationMessage": "You will be logged off in 30 min. Make sure to save your work.",
                  "rampDownStopHostsWhen": "ZeroActiveSessions",
                  "rampDownWaitTimeMinutes": 30,

                  // OFF PEAK //
                  "offPeakStartTime": {
                      "hour": 18,
                      "minute": 0
                  },
                  "offPeakLoadBalancingAlgorithm": "DepthFirst"
              }
          }
          ```
        - Reference the scaling plan in Host Pool Configuration
          ```JSON
          {
            ...
            "ScalingPlan": "ScalingPlan01",
            "StartVMOnConnect": true,
            ...
          }
          ```
  - **AVDMF v1.0.71 (Configuration v1.0.58)**:
    - Fix:
      - Re-introduced Session Host Join Type in Host Pool Configuration, used for Azure AD Joined Session Hosts to assign Virtual Machine User role to users.
  - **AVDMF v1.0.70 (Configuration v1.0.58)**:
    - Fix:
      - Fixed issue where deployment name is invalid for replacement plan.
  - **AVDMF v1.0.68 (Configuration v1.0.58)**:
   - Fix:
     - Fixed an issue where deployment fails if no Remote Apps are defined.
 - **AVDMF v1.0.67 (Configuration v1.0.58)**:
   - New:
     - Storage Accounts are all created with public network access disabled.
 - **AVDMF v1.0.66 (Configuration v1.0.58)**:
   - New:
     - Default subnets of a virtual network can now have NSG and Route Tables assigned. see below example from:  `VirtualNetwork/*.jsonc`
        ```diff
            "DefaultSubnets": [
                {
                    "Scope": "Management",
                    "NamePrefix": "PrivateLinks",
        +           "NSG": "NSG01",
        +           "RouteTable": "RouteTable01",
                    "PrivateLink": false
                }
            ]
        ```
 - **AVDMF v1.0.65 (Configuration v1.0.58)**:
   - Drops the need for TimeZone, SessionHostJoinType, and DomainJoinCredentials in the GeneralConfiguration.jsonc file.
   - This information is now part of the ReplacementPlan and VMTemplate configurations.

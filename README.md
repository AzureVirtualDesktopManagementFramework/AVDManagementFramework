# PSFModule guidance

This is a finished module layout optimized for implementing the PSFramework.

If you don't care to deal with the details, this is what you need to do to get started seeing results:

 - Add the functions you want to publish to `/functions/`
 - Update the `FunctionsToExport` node in the module manifest (AVDManagementFramework.psd1). All functions you want to publish should be in a list.
 - Add internal helper functions the user should not see to `/internal/functions/`

 ## Path Warning

 > If you want your module to be compatible with Linux and MacOS, keep in mind that those OS are case sensitive for paths and files.

 `Import-ModuleFile` is preconfigured to resolve the path of the files specified, so it will reliably convert weird path notations the system can't handle.
 Content imported through that command thus need not mind the path separator.
 If you want to make sure your code too will survive OS-specific path notations, get used to using `Resolve-path` or the more powerful `Resolve-PSFPath`.

 ## change history
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
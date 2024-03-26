function Register-AVDMFHostPool {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
            Application Groups for RemoteApp Host Pools
                {
                    "Name": "Common Apps",
                    "RemoteAppReference":[
                        "SAPAnalyzer",
                        "SAPLogon"
                    ],
                    "Users":[
                        "BusinessAppGroup@oq.com"
                    ]
                }
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $AccessLevel,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [ValidateSet("Personal", "Pooled", "RemoteApp")]
        [string] $PoolType,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolMetadataLocation = $script:Location,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $ReplacementPlan,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $ScalingPlan,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $MaxSessionLimit,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $NumberOfSessionHosts,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $FriendlyName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $WorkSpaceReference,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $VirtualNetworkReference,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $SubnetNSG,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $SubnetRouteTable,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $StorageAccountReference,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        $RemoteAppGroups,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string[]] $Users,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $VMTemplate,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [ValidateSet("AAD", "ADDS")]
        [string] $SessionHostJoinType = "ADDS",

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $UseAvailabilityZones = $false,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $StartVMOnConnect = $false,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $CustomRdpProperty = "drivestoredirect:s:;redirectwebauthn:i:0;redirectlocation:i:0;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;camerastoredirect:s:;autoreconnectionenabled:i:1;",

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {
        #Validate the value of Pooled only parameters against PoolType parameter
        $exclusiveParameters = @(
            @{Name = "ReplacementPlan"; PoolTypes = @("Pooled", "RemoteApp") }
            @{Name = "MaxSessionLimit"; PoolTypes = @("Pooled", "RemoteApp") }
        )
        foreach ($parameter in $exclusiveParameters) {
            $parameterValue = (Get-Variable -Name $parameter.Name -ErrorAction SilentlyContinue).Value
            if ($PoolType -in $parameter.PoolTypes -and ( [string]::IsNullOrEmpty($parameterValue))) {
                $errorMessage = "Parameter ({0}) is required for {1} Host Pools" -f $parameter.Name, ($parameter.PoolTypes -join ' and ')
                Write-PSFMessage -Level Error -Message $errorMessage
                throw $errorMessage
            }
            elseif ($PoolType -notin $parameter.PoolTypes -and (-Not [string]::IsNullOrEmpty($parameterValue))) {
                $errorMessage = "Parameter ({0}) is not supported for {1} Host Pools" -f $parameter.Name, ($parameter.PoolTypes -join ' and ')
                Write-PSFMessage -Level Error -Message $errorMessage
                throw $errorMessage
            }
        }

        $ResourceName = New-AVDMFResourceName -ResourceType 'HostPool' -AccessLevel $AccessLevel -HostPoolType $PoolType
        $resourceGroupName = New-AVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'HostPool' -AccessLevel $AccessLevel -HostPoolType $PoolType
        Register-AVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'HostPool'

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DesktopVirtualization/hostpools/$ResourceName"

        #Register Subnet
        $subnetParams = @{
            Scope              = $AccessLevel + 'Access'  #TODO: Change the parameter name from scope to Access Level, also change it in subnet configurations
            NamePrefix         = $resourceName
            VirtualNetworkName = $script:VirtualNetworks[$VirtualNetworkReference].ResourceName
            VirtualNetworkID   = $script:VirtualNetworks[$VirtualNetworkReference].ResourceID
            NSGID              = $script:NetworkSecurityGroups[$SubnetNSG].ResourceID
            RouteTableID       = $script:RouteTables[$SubnetRouteTable].ResourceID
        }

        $subnetID = Register-AVDMFSubnet @subnetParams -PassThru

        # Pickup Storage Account
        #TODO: Change Storage Accounts into HashTables
        if ($StorageAccountReference) {
            $storageAccount = $script:StorageAccounts[$StorageAccountReference]
            Register-AVDMFFileShare -Name $resourceName.ToLower() -StorageAccountName $storageAccount.Name -ResourceGroupName $storageAccount.ResourceGroupName
        }

        # Get Azure Virtual Desktop App Object Id for permission assignment
        Write-PSFMessage -Level Verbose -Message "Getting Azure Virtual Desktop App (9cdead84-a844-4324-93f2-b2e6bb768d07) Object Id for permission assignment"
        if (-Not $script:Offline) {
            $avdAppObjectId = (Get-AzADServicePrincipal -ApplicationId '9cdead84-a844-4324-93f2-b2e6bb768d07').Id
        }
        else {
            $avdAppObjectId = 'XXXXXX-XXXX-XXXX-XXXX-OFFLINE'
        }

        Write-PSFMessage -Level Verbose -Message "Azure Virtual Desktop App Object Id is: {0}" -StringValues $avdAppObjectId

        $script:HostPools[$ResourceName] = [PSCustomObject]@{
            PSTypeName           = 'AVDMF.DesktopVirtualization.HostPool'
            ResourceGroupName    = $resourceGroupName
            ResourceID           = $resourceID

            Location             = $HostPoolMetadataLocation
            PoolType             = $PoolType
            MaxSessionLimit      = $MaxSessionLimit
            NumberOfSessionHosts = $NumberOfSessionHosts
            CustomRdpProperty    = $CustomRdpProperty
            StartVMOnConnect     = $StartVMOnConnect
            AVDAppObjectId       = $avdAppObjectId

            WorkSpaceReference   = $WorkSpaceReference

            SubnetID             = $subnetID

            VMTemplate           = $VMTemplate

            # SessionHostJoinType  = $script:SessionHostJoinType

            Tags                 = $Tags



        }
        #TODO: Check if users are provided.
        if ($PoolType -eq "RemoteApp") {
            # We assume only Remote App AGs are used for RemoteApp Host Pools
            foreach ($applicationGroup in $RemoteAppGroups) {
                # Register each application group
                $applicationGroupParams = @{
                    HostPoolName         = $resourceName
                    ResourceGroupName    = $resourceGroupName
                    Location             = $HostPoolMetadataLocation
                    HostPoolResourceId   = $resourceID
                    Users                = $applicationGroup.Users
                    Name                 = $applicationGroup.Name
                    FriendlyName         = $applicationGroup.Name
                    ApplicationGroupType = 'RemoteApp'
                    RemoteAppReference   = $applicationGroup.RemoteAppReference
                    SessionHostJoinType  = $SessionHostJoinType


                }
                #TODO: Add logic to check if all remote app references exist
                Register-AVDMFApplicationGroup @applicationGroupParams -ErrorAction Stop
            }
        }
        else {
            # This would apply for pooled and personal pools. Only creating one AG of type Desktop.
            $applicationGroupParams = @{
                HostPoolName         = $resourceName
                ResourceGroupName    = $resourceGroupName
                Location             = $HostPoolMetadataLocation
                HostPoolResourceId   = $resourceID
                Users                = $Users
                Name                 = "Desktop"
                FriendlyName         = $FriendlyName
                ApplicationGroupType = 'Desktop'
                SessionHostJoinType  = $SessionHostJoinType

            }
            Register-AVDMFApplicationGroup @applicationGroupParams
        }

        # Register Scaling Plan
        if (-Not [string]::IsNullOrEmpty($ScalingPlan)) {
            $scalingPlanParams = @{
                ResourceGroupName   = $resourceGroupName
                Location            = $HostPoolMetadataLocation
                HostPoolName        = $resourceName
                HostPoolId          = $resourceID
                ScalingPlanTemplate = $script:ScalingPlanTemplates[$ScalingPlan]
            }
            Register-AVDMFScalingPlan @scalingPlanParams
        }

        # Register TemplateSpec
        $templateSpecParams = @{
            ResourceGroupName = $resourceGroupName
            HostPoolName      = $resourceName
            TemplateFileName  = $script:VMTemplates[$VMTemplate].TemplateFileName
        }
        $templateSpecResourceId = Register-AVDMFTemplateSpec @templateSpecParams



        # Register Replacement Plan
        $hostPoolInstance = $ResourceName.Substring($ResourceName.Length - 2, 2)
        $sessionHostNamePrefix = New-AVDMFResourceName -ResourceType 'SessionHostPrefix' -AccessLevel $AccessLevel -HostPoolType $PoolType -HostPoolInstance $hostPoolInstance

        $hostPoolSessionHostParameters = $script:VMTemplates[$VMTemplate].Parameters | ConvertFrom-Json -Depth 99 -AsHashtable
        $hostPoolSessionHostParameters['SubnetID'] = $subnetID


        $replacementPlanParams = @{
            ResourceGroupName       = $resourceGroupName
            HostPoolName            = $resourceName
            TargetSessionHostCount  = $NumberOfSessionHosts
            SessionHostNamePrefix   = $sessionHostNamePrefix
            SubnetId                = $subnetID
            ReplacementPlanTemplate = $script:ReplacementPlanTemplates[$ReplacementPlan]
            SessionHostParameters   = $hostPoolSessionHostParameters | ConvertTo-Json -Depth 99 -Compress
            SessionHostTemplate     = $templateSpecResourceId
        }
        if (-Not [string]::IsNullOrEmpty($ScalingPlan)) {

            $replacementPlanParams.ScalingPlanExclusionTag = $script:ScalingPlanTemplates[$ScalingPlan].ExclusionTag
        }
        Register-AVDMFReplacementPlan @replacementPlanParams
    }
}
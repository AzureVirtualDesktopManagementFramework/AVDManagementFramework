function Register-AVDMFApplicationGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolResourceId,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $Name,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $FriendlyName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [ValidateSet('Desktop', 'RemoteApp')]
        [string] $ApplicationGroupType,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string[]] $RemoteAppReference,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string[]] $Users,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [ValidateSet("AAD", "ADDS")]
        [string] $SessionHostJoinType = "ADDS",

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {
        $resourceName = New-AVDMFResourceName -ResourceType 'ApplicationGroup' -ParentName $HostPoolName -NameSuffix $Name

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DesktopVirtualization/applicationgroups/$ResourceName"

        $principalId = @()
        if ($Users.count -ge 1) {
            $principalId += foreach ($user in $Users) {
                try {
                    if ($user -like "*@*" ) {
                        Write-PSFMessage -Level Verbose -Message "Resolving Id for user: $user"
                        $id = (Get-AzADUser -UserPrincipalName $user -ErrorAction Stop).Id
                    }
                    else {
                        Write-PSFMessage -Level Verbose -Message "Resolving Id for group: $user"
                        $id = (Get-AzADGroup -DisplayName $user -ErrorAction Stop).Id
                    }
                    if ($null -eq $id) {
                        throw
                    }
                    $id
                }
                catch {
                    throw "Could not resolve id for $user - If the name is correct then ensure the service principal used is assigned 'Directory readers' role."
                }
            }
        }

        $script:ApplicationGroups[$resourceName] = [PSCustomObject]@{
            PSTypeName           = 'AVDMF.DesktopVirtualization.ApplicationGroup'
            ResourceGroupName    = $ResourceGroupName
            HostPoolId           = $HostPoolResourceId
            ApplicationGroupType = $ApplicationGroupType
            FriendlyName         = $FriendlyName
            PrincipalId          = $principalId
            SessionHostJoinType  = $SessionHostJoinType
            Tags                 = $Tags
        }

        # Link Application group to workspace
        $script:Workspaces.GetEnumerator() | Where-Object { $_.value.ReferenceName -eq $script:hostpools.$hostpoolname.WorkspaceReference } | ForEach-Object { $_.value.ApplicationGroupReferences += $resourceID }


        # Register remote Apps
        if ($RemoteAppReference) {
            Write-PSFMessage -Level Verbose -Message "Registering Remote Apps"
            foreach ($remoteApp in $RemoteAppReference) {
                if ($script:RemoteAppTemplates[$remoteApp]) {
                    $registerRemoteAppParams = @{
                        ResourceGroupName    = $resourceGroupName
                        ApplicationGroupName = $resourceName
                        RemoteAppTemplate    = $script:RemoteAppTemplates[$remoteApp]
                    }
                    Register-AVDMFRemoteApp @registerRemoteAppParams
                }
                else {
                    throw "Could not find RemoteApp Template: $remoteApp"
                }
            }
        }
    }
}
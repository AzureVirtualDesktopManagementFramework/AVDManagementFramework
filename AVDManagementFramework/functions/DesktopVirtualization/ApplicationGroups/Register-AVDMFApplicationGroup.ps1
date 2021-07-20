function Register-AVDMFApplicationGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolResourceId,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string[]] $Users,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {
        $ResourceName = New-AVDMFResourceName -ResourceType 'ApplicationGroup' -ParentName $HostPoolName

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
                    if($null -eq $id){
                        throw
                    }
                }
                catch {
                    throw "Could not resolve id for $user - If the name is correct then ensure the service principal used is assigned 'Directory readers' role."
                }
            }
        }

        $script:ApplicationGroups[$ResourceName] = [PSCustomObject]@{
            PSTypeName        = 'AVDMF.DesktopVirtualization.ApplicationGroup'
            ResourceGroupName = $ResourceGroupName
            HostPoolId        = $HostPoolResourceId
            PrincipalId       = $principalId
            Tags              = $Tags
        }

        # Link Application group to workspace
        $script:Workspaces.GetEnumerator() | Where-Object { $_.value.ReferenceName -eq $script:hostpools.$hostpoolname.WorkspaceReference } | ForEach-Object { $_.value.ApplicationGroupReferences += $resourceID }

    }
}
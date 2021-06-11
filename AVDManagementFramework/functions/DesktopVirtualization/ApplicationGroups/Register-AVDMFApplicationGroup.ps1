function Register-AVDMFApplicationGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolResourceId,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Alias("Tags")]
        [hashtable] $ResourceTags = @{}
    )
    process{
        $ResourceName = New-AVDMFResourceName -ResourceType 'ApplicationGroup' -ParentName $HostPoolName

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DesktopVirtualization/applicationgroups/$ResourceName"

        $script:ApplicationGroups[$ResourceName] = [PSCustomObject]@{
            PSTypeName        = 'AVDMF.DesktopVirtualization.ApplicationGroup'
            ResourceGroupName = $ResourceGroupName
            HostPoolId        = $HostPoolResourceId
            Tags = $ResourceTags
        }

        # Link Application group to workspace
        $script:Workspaces.GetEnumerator()  | Where-Object {$_.value.ReferenceName -eq $script:hostpools.$hostpoolname.WorkspaceReference } | ForEach-Object {$_.value.ApplicationGroupReferences += $resourceID}

    }
}
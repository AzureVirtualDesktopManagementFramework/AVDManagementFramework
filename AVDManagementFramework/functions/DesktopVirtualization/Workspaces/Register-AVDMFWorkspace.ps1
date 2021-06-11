function Register-AVDMFWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $AccessLevel,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolType,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {
        $ResourceName = New-AVDMFResourceName -ResourceType 'Workspace' -AccessLevel $AccessLevel -HostPoolType $HostPoolType
        $resourceGroupName = New-AVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Workspace' -AccessLevel $AccessLevel -HostPoolType $HostPoolType
        Register-AVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Workspace'

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DesktopVirtualization/workspaces/$ResourceName"

        $script:Workspaces[$ResourceName] = [PSCustomObject]@{
            PSTypeName                 = 'AVDMF.DesktopVirtualization.Workspace'
            ResourceID                 = $resourceID
            ReferenceName              = $ReferenceName
            ResourceGroupName          = $resourceGroupName
            ApplicationGroupReferences = @()
            Tags = $Tags
        }
    }
}
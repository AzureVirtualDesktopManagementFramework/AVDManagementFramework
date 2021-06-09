function Register-WVDMFWorkspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $AccessLevel,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolType,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName
    )
    process {
        $ResourceName = New-WVDMFResourceName -ResourceType 'Workspace' -AccessLevel $AccessLevel -HostPoolType $HostPoolType
        $resourceGroupName = New-WVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Workspace' -AccessLevel $AccessLevel -HostPoolType $HostPoolType
        Register-WVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Workspace'

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.DesktopVirtualization/workspaces/$ResourceName"

        $script:Workspaces[$ResourceName] = [PSCustomObject]@{
            PSTypeName                 = 'WVDMF.DesktopVirtualization.Workspace'
            ResourceID                 = $resourceID
            ReferenceName              = $ReferenceName
            ResourceGroupName          = $resourceGroupName
            ApplicationGroupReferences = @()
        }
    }
}
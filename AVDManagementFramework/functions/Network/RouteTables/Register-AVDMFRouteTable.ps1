function Register-AVDMFRouteTable {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [array] $Routes,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Boolean] $DisableBgpRoutePropagation,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $AccessLevel,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $HostPoolType,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {
        $resourceName = New-AVDMFResourceName -ResourceType 'RouteTable' -AccessLevel $AccessLevel -HostPoolType $HostPoolType

        #Register Resource Group if needed
        $resourceGroupName = New-AVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Network' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -InstanceNumber 1
        # At the moment we do not have a reason for multiple network RGs.
        Register-AVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Network'

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/routeTables/$resourceName"

        $routesHashTable = @($Routes | ForEach-Object { $_ | ConvertTo-PSFHashtable })
        foreach ($item in $routesHashTable) {
            $item.properties = $item.properties | ConvertTo-PSFHashtable
        }

        $script:RouteTables[$ReferenceName] = [PSCustomObject]@{
            PSTypeName                 = 'AVDMF.Network.RouteTable'
            ResourceName               = $resourceName
            ResourceGroupName          = $resourceGroupName
            ResourceID                 = $resourceID
            ReferenceName              = $ReferenceName
            Routes                     = $routesHashTable #@($Routes | ForEach-Object { $_ | ConvertTo-PSFHashtable })
            DisableBgpRoutePropagation = $DisableBgpRoutePropagation
            Tags                       = $Tags
        }
    }
}
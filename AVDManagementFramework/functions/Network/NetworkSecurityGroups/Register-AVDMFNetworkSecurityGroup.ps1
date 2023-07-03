function Register-AVDMFNetworkSecurityGroup {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ReferenceName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [array] $SecurityRules,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $AccessLevel,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $HostPoolType,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {
        $resourceName = New-AVDMFResourceName -ResourceType 'NetworkSecurityGroup' -AccessLevel $AccessLevel -HostPoolType $HostPoolType

        #Register Resource Group if needed
        $resourceGroupName = New-AVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Network' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -InstanceNumber 1
        # At the moment we do not have a reason for multiple network RGs.
        Register-AVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Network'

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/networkSecurityGroups/$resourceName"


        $script:NetworkSecurityGroups[$ReferenceName] = [PSCustomObject]@{
            PSTypeName        = 'AVDMF.Network.NetworkSecurityGroup'
            ResourceName      = $resourceName
            ResourceGroupName = $resourceGroupName
            ResourceID        = $resourceID
            ReferenceName     = $ReferenceName
            SecurityRules     = if($SecurityRules ) {@($SecurityRules | ForEach-Object { $_ | ConvertTo-PSFHashtable })} else {$null}
            Tags = $Tags
        }
    }
}
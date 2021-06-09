function Register-WVDMFNetworkSecurityGroup {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [array] $SecurityRules,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $AccessLevel,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $HostPoolType
    )
    process {
        $resourceName = New-WVDMFResourceName -ResourceType 'NetworkSecurityGroup' -AccessLevel $AccessLevel -HostPoolType $HostPoolType

        #Register Resource Group if needed
        $resourceGroupName = New-WVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Network' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -InstanceNumber 1
        # At the moment we do not have a reason for multiple network RGs.
        Register-WVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Network'

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/networkSecurityGroups/$resourceName"


        $script:NetworkSecurityGroups[$ReferenceName] = [PSCustomObject]@{
            PSTypeName        = 'WVDMF.Network.NetworkSecurityGroup'
            ResourceName      = $resourceName
            ResourceGroupName = $resourceGroupName
            ResourceID        = $resourceID
            ReferenceName     = $ReferenceName
            SecurityRules     = @($SecurityRules | ForEach-Object { $_ | ConvertTo-PSFHashtable })
        }
    }
}
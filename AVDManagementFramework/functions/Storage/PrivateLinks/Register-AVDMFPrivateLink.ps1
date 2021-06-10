function Register-AVDMFPrivateLink {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $StorageAccountID

    )
    process {
        $SubnetId = $script:subnets[($script:subnets.keys | Where-Object { $_ -like 'PrivateLinks*' })].ResourceId

        $resourceName = New-AVDMFResourceName -ResourceType 'PrivateLink' -ParentName $StorageAccountName

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/privateEndpoints/$ResourceName"

        $script:PrivateLinks += [PSCustomObject]@{
            PSTypeName        = 'AVDMF.Storage.PrivateLink'
            Name              = $resourceName
            ResourceGroupName = $resourceGroupName
            ResourceID        = $resourceID

            StorageAccountID  = $StorageAccountID
            SubnetID          = $SubnetId

        }
    }
}
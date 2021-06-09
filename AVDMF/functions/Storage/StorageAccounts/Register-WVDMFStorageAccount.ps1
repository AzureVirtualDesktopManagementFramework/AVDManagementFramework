function Register-WVDMFStorageAccount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $AccessLevel,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $accountType,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolType,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $Kind,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $shareSoftDeleteRetentionDays
    )
    process {
        $ResourceName = New-WVDMFResourceName -ResourceType 'StorageAccount' -AccessLevel $AccessLevel -HostPoolType $HostPoolType
        $resourceGroupName = New-WVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Storage' -AccessLevel 'All' -HostPoolType 'All' -InstanceNumber 1
        Register-WVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Storage'
        # At the moment we do not have a reason for multiple storage RGs.

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$ResourceName"

        $script:StorageAccounts += [PSCustomObject]@{
            PSTypeName        = 'WVDMF.Storage.StorageAccount'
            Name              = $ResourceName
            ResourceGroupName = $resourceGroupName
            ResourceID        = $resourceID

            ReferenceName     = $ReferenceName
            AccountType       = $accountType
            Kind              = $Kind
            SoftDeleteDays    = $ShareSoftDeleteRetentionDays
        }

        #register Private Link
        Register-WVDMFPrivateLink -ResourceGroupName $resourceGroupName -StorageAccountName $ResourceName -StorageAccountID $resourceID
    }
}
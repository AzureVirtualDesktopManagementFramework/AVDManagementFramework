function Register-AVDMFStorageAccount {
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
        [int] $shareSoftDeleteRetentionDays,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $UniqueNameString,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {

        $ResourceName = New-AVDMFResourceName -ResourceType 'StorageAccount' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -UniqueNameString $UniqueNameString

        $resourceGroupName = New-AVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Storage' -AccessLevel 'All' -HostPoolType 'All' -InstanceNumber 1
        Register-AVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Storage'
        # At the moment we do not have a reason for multiple storage RGs.

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$ResourceName"

        $script:StorageAccounts[$ReferenceName] = [PSCustomObject]@{
            PSTypeName        = 'AVDMF.Storage.StorageAccount'
            ResourceGroupName = $resourceGroupName
            ResourceID        = $resourceID
            Name              = $ResourceName
            ReferenceName     = $ReferenceName
            AccountType       = $accountType
            Kind              = $Kind
            SoftDeleteDays    = $ShareSoftDeleteRetentionDays
            Tags              = $Tags
        }

        #register Private Link
        Register-AVDMFPrivateLink -ResourceGroupName $resourceGroupName -StorageAccountName $ResourceName -StorageAccountID $resourceID
    }
}
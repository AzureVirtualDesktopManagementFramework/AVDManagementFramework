function Register-AVDMFFileShareAutoGrowLogicApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $StorageAccountResourceId,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $TargetFreeSpaceGB,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $Enabled = $true,



        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )

    $storageAccountName = $StorageAccountResourceId | Split-Path -Leaf
    $resourceName = New-AVDMFResourceName -ResourceType 'LogicApp' -ParentName $StorageAccountName -NameSuffix "FileShareAutoGrow"

    $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows/$resourceName"


    $script:FileShareAutoGrowLogicApps[$resourceName] = [PSCustomObject]@{
        PSTypeName               = 'AVDMF.Storage.FileShareAutoGrowLogicApp'
        ResourceGroupName        = $resourceGroupName
        ResourceID               = $resourceID
        Name                     = $ResourceName
        StorageAccountResourceId = $StorageAccountResourceId
        TargetFreeSpaceGB        = $TargetFreeSpaceGB
        Enabled                  = $Enabled
        Tags                     = $Tags
    }

}
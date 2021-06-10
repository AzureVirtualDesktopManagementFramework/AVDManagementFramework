function Register-AVDMFFileShare {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $StorageAccountName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ResourceGroupName
    )
    process {
        $script:FileShares[$Name] = [PSCustomObject]@{
            PSTypeName         = 'AVDMF.Storage.FileShare'
            ResourceName       = $Name
            ResourceGroupName  = $resourceGroupName
            StorageAccountName = $StorageAccountName
        }
    }
}
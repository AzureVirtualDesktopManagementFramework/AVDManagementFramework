function Initialize-WVDMFStorage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]

    param (
        [string] $ResourceGroupName
    )

    $filteredStorageAccounts = @()
    $filteredPrivateLinks = @()
    $filteredFileShares = @{}

    foreach ($item in ($script:StorageAccounts | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }) ) {
        $filteredStorageAccounts += $item
    }

    foreach ($item in ($script:PrivateLinks | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }) ) {
        $filteredPrivateLinks += $item
    }

    $script:FileShares.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object {$filteredFileShares.Add($_.Key, $_.Value)}


    $templateParams = @{
        StorageAccounts = [array] ($filteredStorageAccounts | ConvertTo-PSFHashtable)
        PrivateLinks = [array] ($filteredPrivateLinks | ConvertTo-PSFHashtable)
        FileShares = [array] ($filteredFileShares | Convert-HashtableToArray)
    }
    $templateParams

}
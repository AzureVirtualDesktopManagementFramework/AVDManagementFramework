function Initialize-AVDMFStorage {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]

    param (
        [string] $ResourceGroupName
    )

    $filteredStorageAccounts = @{}
    $filteredPrivateLinks = @{}
    $filteredFileShares = @{}
    $filteredFileShareAutoGrowLogicApps = @{}

    $script:StorageAccounts.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredStorageAccounts.Add($_.Key, $_.Value) }

    $script:PrivateLinks.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredPrivateLinks.Add($_.Key, $_.Value) }

    $script:FileShares.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredFileShares.Add($_.Key, $_.Value) }

    $script:FileShareAutoGrowLogicApps.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredFileShareAutoGrowLogicApps.Add($_.Key, $_.Value) }


    $templateParams = @{
        StorageAccounts            = [array] ($filteredStorageAccounts | Convert-HashtableToArray)
        PrivateLinks               = [array] ($filteredPrivateLinks | Convert-HashtableToArray)
        FileShares                 = [array] ($filteredFileShares | Convert-HashtableToArray)
        FileShareAutoGrowLogicApps = [array] ($filteredFileShareAutoGrowLogicApps | Convert-HashtableToArray)
    }
    $templateParams

}
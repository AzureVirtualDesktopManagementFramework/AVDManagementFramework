function Set-AVDMFNameMapping {
    <#
    .SYNOPSIS
        Takes a dataset and converts any %XXXX% into mapping.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable] $Dataset
    )

    foreach ($item in ($dataset.GetEnumerator() | Where-Object { $null -ne $_.Value } )){

        #if ($null -eq $item.Value) { continue } # Value is null nothing to replace
        if ($item.Value.GetType().Name -eq 'String'){
            $stringMappings = ([regex]::Matches($item.Value, '%.+?%')).Value | ForEach-Object { if ($_) { $_ -replace "%", "" } }
            foreach ($mapping in $stringMappings) {
                $mappedValue = $script:NameMappings[$mapping]
                $item.Value = $item.Value -replace "%$mapping%", $mappedValue
            }
            $dataset[$item.Key] = $item.Value
        }
        if ($item.Value.GetType().Name -eq 'PSCustomObject') {
            $dataset[$item.Key] =[PSCustomObject] (Set-AVDMFNameMapping -Dataset ($item.Value | ConvertTo-PSFHashtable))
        }
    }
    $Dataset
}
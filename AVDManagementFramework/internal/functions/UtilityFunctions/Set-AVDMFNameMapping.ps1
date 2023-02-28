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
        if ($item.Value.GetType().Name -eq 'String'){
            $stringMappings = ([regex]::Matches($item.Value, '%.+?%')).Value | ForEach-Object { if ($_) { $_ -replace "%", "" } }
            foreach ($mapping in $stringMappings) {
                $mappedValue = $script:NameMappings[$mapping]
                if($null -ne $mappedValue ){
                    $item.Value = $item.Value -replace "%$mapping%", $mappedValue
                }
            }
            $dataset[$item.Key] = $item.Value
        }
        if ($item.Value.GetType().Name -eq 'PSCustomObject') {
            $dataset[$item.Key] =[PSCustomObject] (Set-AVDMFNameMapping -Dataset ($item.Value | ConvertTo-PSFHashtable))
        }
        if ($item.Value.GetType().Name -eq 'Object[]') {
            for($i=0;$i -lt $item.Value.Count;$i++){
                if($item.Value[$i].GetType().Name -eq 'String'){
                    $stringMappings = ([regex]::Matches($item.Value[$i], '%.+?%')).Value | ForEach-Object { if ($_) { $_ -replace "%", "" } }
                    foreach ($mapping in $stringMappings) {
                        $mappedValue = $script:NameMappings[$mapping]
                        $item.Value[$i] = $item.Value[$i] -replace "%$mapping%", $mappedValue
                    }
                }
                if($item.Value[$i].GetType().Name -eq  'PSCustomObject' ){
                    $item.Value[$i] = [PSCustomObject] (Set-AVDMFNameMapping -Dataset ($item.Value[$i] | ConvertTo-PSFHashtable))
                }
            }
        }
    }
    $Dataset
}
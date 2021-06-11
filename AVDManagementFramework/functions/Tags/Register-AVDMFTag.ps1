function Register-AVDMFTag {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ResourceType,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PSCustomObject] $Tags
    )
    process {
        $Tags = $Tags | ConvertTo-PSFHashtable
        # Name Mappings
        foreach ($item in ($Tags.GetEnumerator() | Where-Object {$_.Value.GetType().Name -eq 'String'})){
            $nameMappings = ([regex]::Matches($item.Value,'%.+?%')).Value | ForEach-Object {if($_) {$_ -replace "%",""}}
            foreach ($mapping in $nameMappings){
                $mappedValue = $script:NameMappings[$mapping]
                $item.Value = $item.Value -replace "%$mapping%",$mappedValue
            }
            $Tags[$item.Key] = $item.Value
        }
        #TODO: Create a name mapping function that converts all types.
        $script:Tags[$ResourceType] = $Tags
    }
}
function Convert-HashtableToArray {
    [OutputType('System.Array')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline=$true )]
        [Hashtable] $InputObject
    )
    process {
        $output = foreach ($key in $InputObject.Keys){
            $object = @{
                Name = $key
            }
            $Members = $InputObject[$key] | Get-Member -MemberType NoteProperty # TODO: $hash['h104p01-vnet-pv-01'].psobject.Properties.name
            $Members | ForEach-Object {$object[$_.Name] = $InputObject[$key].($_.Name)}

            $object
        }

        ,$output # "The comma makes it output an array ALWAYS, that's it" -Fred!
    }
}
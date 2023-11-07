function ConvertFrom-JSONParameters {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipeline = $true )]
        [string] $JSONParameters
    )
    $JSONParameters | ConvertFrom-Json | Get-Member -MemberType NoteProperty | Sort-Object -Property Name| ForEach-Object {
        @"
[Parameter(Mandatory = `$true , ValueFromPipelineByPropertyName = `$true )]
[string] `$$($_.Name),

"@
    }
}
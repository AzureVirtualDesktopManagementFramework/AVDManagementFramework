function Register-AVDMFGlobalTag {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ResourceType,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PSCustomObject] $Tags
    )
    process {
        $Tags = $Tags | ConvertTo-PSFHashtable
        $script:GlobalTags[$ResourceType] = $Tags
    }
}
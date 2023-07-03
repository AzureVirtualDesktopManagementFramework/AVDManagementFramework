function Register-AVDMFVMTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [PSCustomObject] $Parameters
    )
    process {
        $script:VMTemplates[$ReferenceName] = @{
            Parameters = $Parameters | ConvertTo-Json -Depth 100 -Compress
        }
    }
}
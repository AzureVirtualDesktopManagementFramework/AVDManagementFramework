function Register-AVDMFVMTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [PSCustomObject] $Parameters,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $TemplateFileName
    )
    process {
        $script:VMTemplates[$ReferenceName] = @{
            Parameters       = $Parameters | ConvertTo-Json -Depth 100 -Compress # Converting to JSON as this is how it is stored as a FunctipnApp Configuration.
            TemplateFileName = $TemplateFileName
        }
    }
}
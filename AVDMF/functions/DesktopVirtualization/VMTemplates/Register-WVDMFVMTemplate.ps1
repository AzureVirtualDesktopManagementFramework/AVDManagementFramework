function Register-WVDMFVMTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $AdminUsername,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $VMSize,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [Object] $ImageReference,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $WVDArtifactsURL
    )
    process {
        $script:VMTemplates[$ReferenceName] = @{
            AdminUserName   = $AdminUsername
            AdminPassword   = Get-RandomPassword
            VMSize          = $VMSize
            ImageReference  = $ImageReference | ConvertTo-PSFHashtable
            WVDArtifactsURL = $WVDArtifactsURL
        }
    }
}
function Register-AVDMFRemoteAppTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $Name,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        $Properties

    )
    process {
        #TODO: Validate inputs would create a working remote app

        #register Remote App Template
        $script:RemoteAppTemplates[$ReferenceName] = [PSCustomObject]@{
            PSTypeName          = 'AVDMF.DesktopVirtualization.RemoteAppTemplate'
            RemoteAppName       = $Name
            RemoteAppProperties = $Properties
        }
    }
}
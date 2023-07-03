function Register-AVDMFRemoteApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ApplicationGroupName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [object] $RemoteAppTemplate
    )
    process {
        $resourceName = "$ApplicationGroupName/$($RemoteAppTemplate.RemoteAppName)"
        Write-PSFMessage -Level Verbose -Message "Registering Remote App: $resourceName"
        #TODO: Validate inputs would create a working remote app
        #register Remote App
        $script:RemoteApps[$resourceName] = [PSCustomObject]@{
            PSTypeName           = 'AVDMF.DesktopVirtualization.RemoteApp'
            ResourceGroupName    = $ResourceGroupName
            ApplicationGroupName = $ApplicationGroupName
            RemoteAppName        = $RemoteAppTemplate.RemoteAppName
            RemoteAppProperties  = $RemoteAppTemplate.RemoteAppProperties | ConvertTo-PSFHashtable
        }

    }
}
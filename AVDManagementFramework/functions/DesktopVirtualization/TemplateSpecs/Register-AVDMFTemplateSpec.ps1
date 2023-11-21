function Register-AVDMFTemplateSpec {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $TemplateFileName

    )

    $resourceName = New-AVDMFResourceName -ResourceType 'TemplateSpec' -ParentName $HostPoolName -InstanceNumber 1
    $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Resources/templateSpecs/$resourceName"

    $templateFilePath = Join-PSFPath -Path $script:ConfigurationPath -Child 'DesktopVirtualization', 'VMTemplates', 'TemplateFiles', $TemplateFileName
    Write-PSFMessage -Level Verbose -Message "Loading bicep file from {0}" -StringValues $templateFilePath

    $templateJSON = [string] (bicep build $templateFilePath --stdout )
    if ([string]::IsNullOrEmpty($templateJSON)) {
        Stop-PSFFunction -Message "Could not load VM Template file: $templateFilePath" -EnableException $true -Category InvalidData
    }

    $script:TemplateSpecs[$resourceName] = [PSCustomObject]@{
        PSTypeName        = 'AVDMF.DesktopVirtualization.TemplateSpec'
        ResourceGroupName = $ResourceGroupName
        ResourceID        = $resourceID

        TemplateFileName  = $TemplateFileName
        TemplateJSON      = $templateJSON
    }

    $resourceID

}
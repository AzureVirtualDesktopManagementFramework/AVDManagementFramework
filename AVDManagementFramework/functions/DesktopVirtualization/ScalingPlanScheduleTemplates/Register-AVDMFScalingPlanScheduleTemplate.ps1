function Register-AVDMFScalingPlanScheduleTemplate {
    <#
    .SYNOPSIS
        This function registers a scaling plan schedule template.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [PSCustomObject] $Parameters
    )

    #register AVD Replacement Plan Template
    $script:ScalingPlanScheduleTemplates[$ReferenceName] = [PSCustomObject]@{
        PSTypeName = 'AVDMF.DesktopVirtualization.AVDScalingPlanScheduleTemplate'
        Parameters = $Parameters | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable
    }
}
function Register-AVDMFReplacementPlanTemplate {
    <#
    .SYNOPSIS
        This function registers a replacement plan template.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReplacementPlanNameSuffix,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $AVDReplacementPlanURL,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $AssignPermissions = $true,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $TagDeployTimestamp,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $TagIncludeInAutomation,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $TagPendingDrainTimestamp,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $TargetVMAgeDays,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $DrainGracePeriodHours,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [bool] $FixSessionHostTags,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $SHRDeploymentPrefix,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $MaxSimultaneousDeployments,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $SessionHostTemplateUri,

        #[Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        #[string] $SessionHostTemplateParametersPS1Uri,


        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $SessionHostInstanceNumberPadding = 2,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $ReplaceSessionHostOnNewImageVersion = $true,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $ReplaceSessionHostOnNewImageVersionDelayDays = 0,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )

    #register AVD Replacement Plan Template
    $script:ReplacementPlanTemplates[$ReferenceName] = [PSCustomObject]@{
        PSTypeName                                   = 'AVDMF.DesktopVirtualization.AVDReplacementPlanTemplate'
        ReplacementPlanNameSuffix                    = $ReplacementPlanNameSuffix
        AVDReplacementPlanURL                        = $AVDReplacementPlanURL
        AssignPermissions                            = $AssignPermissions
        TagDeployTimestamp                           = $TagDeployTimestamp
        TagIncludeInAutomation                       = $TagIncludeInAutomation
        TagPendingDrainTimestamp                     = $TagPendingDrainTimestamp
        TargetVMAgeDays                              = $TargetVMAgeDays
        DrainGracePeriodHours                        = $DrainGracePeriodHours
        FixSessionHostTags                           = $FixSessionHostTags
        SHRDeploymentPrefix                          = $SHRDeploymentPrefix
        MaxSimultaneousDeployments                   = $MaxSimultaneousDeployments
        SessionHostTemplateUri                       = $SessionHostTemplateUri
        #SessionHostTemplateParametersPS1Uri = $SessionHostTemplateParametersPS1Uri
        #SessionHostParameters               = $SessionHostParameters | ConvertTo-Json -Depth 100 -Compress
        SessionHostInstanceNumberPadding             = $SessionHostInstanceNumberPadding
        ReplaceSessionHostOnNewImageVersion          = $ReplaceSessionHostOnNewImageVersion
        ReplaceSessionHostOnNewImageVersionDelayDays = $ReplaceSessionHostOnNewImageVersionDelayDays
        Tags                                         = $Tags
    }
}
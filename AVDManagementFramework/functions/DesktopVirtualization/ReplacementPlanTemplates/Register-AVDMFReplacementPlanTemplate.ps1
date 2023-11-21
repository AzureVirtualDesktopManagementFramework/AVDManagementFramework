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

        [PSCustomObject] $Tags = [PSCustomObject]@{},

        ### This is generated from replacement plan parameters helper script
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $AllowDownsizing = $true,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $AppPlanName = 'Y1',
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $AppPlanTier = 'Dynamic',
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $DrainGracePeriodHours = 24,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $FixSessionHostTags = $true,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $FunctionAppZipUrl = 'https://github.com/WillyMoselhy/AVDReplacementPlans/releases/download/v0.1.5/FunctionApp.zip',
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $MaxSimultaneousDeployments = 20,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $ReplaceSessionHostOnNewImageVersion = $true,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $ReplaceSessionHostOnNewImageVersionDelayDays = 0,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $SessionHostInstanceNumberPadding = 2,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $SHRDeploymentPrefix = 'AVDSessionHostReplacer',
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $TagDeployTimestamp = 'AutoReplaceDeployTimestamp',
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $TagIncludeInAutomation = 'IncludeInAutoReplace',
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $TagPendingDrainTimestamp = 'AutoReplacePendingDrainTimestamp',
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [int] $TargetVMAgeDays = 45,
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [bool] $RemoveAzureADDevice



    )

    #register AVD Replacement Plan Template
    $script:ReplacementPlanTemplates[$ReferenceName] = [PSCustomObject]@{
        PSTypeName                                   = 'AVDMF.DesktopVirtualization.AVDReplacementPlanTemplate'
        ReplacementPlanNameSuffix                    = $ReplacementPlanNameSuffix
        Tags                                         = $Tags
        ### This is generated from replacement plan parameters helper script

        AllowDownsizing                              = $AllowDownsizing
        AppPlanName                                  = $AppPlanName
        AppPlanTier                                  = $AppPlanTier
        DrainGracePeriodHours                        = $DrainGracePeriodHours
        FixSessionHostTags                           = $FixSessionHostTags
        FunctionAppZipUrl                            = $FunctionAppZipUrl
        MaxSimultaneousDeployments                   = $MaxSimultaneousDeployments
        ReplaceSessionHostOnNewImageVersion          = $ReplaceSessionHostOnNewImageVersion
        ReplaceSessionHostOnNewImageVersionDelayDays = $ReplaceSessionHostOnNewImageVersionDelayDays
        SessionHostInstanceNumberPadding             = $SessionHostInstanceNumberPadding
        SHRDeploymentPrefix                          = $SHRDeploymentPrefix
        TagDeployTimestamp                           = $TagDeployTimestamp
        TagIncludeInAutomation                       = $TagIncludeInAutomation
        TagPendingDrainTimestamp                     = $TagPendingDrainTimestamp
        TargetVMAgeDays                              = $TargetVMAgeDays
        RemoveAzureADDevice                          = $RemoveAzureADDevice
    }
}
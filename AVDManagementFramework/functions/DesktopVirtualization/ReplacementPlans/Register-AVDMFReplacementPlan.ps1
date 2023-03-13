function Register-AVDMFReplacementPlan {
    <#
    .SYNOPSIS
        This function registers a replacement plan for a host pool.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [int] $TargetSessionHostCount,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $SessionHostNamePrefix,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $ADOrganizationalUnitPath,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $SubnetId,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [object] $ReplacementPlanTemplate,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [bool] $UseAvailabilityZones = $false,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $UniqueNameString = "",

        [PSCustomObject] $SessionHostParameters,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    $resourceName = New-AVDMFResourceName -ResourceType 'FunctionApp' -ParentName $HostPoolName -InstanceNumber 1 -UniqueNameString $UniqueNameString -NameSuffix $ReplacementPlanTemplate.ReplacementPlanNameSuffix
    $script:ReplacementPlans[$resourceName] = [PSCustomObject]@{
        ResourceGroupName                            = $ResourceGroupName
        HostPoolName                                 = $HostPoolName
        TargetSessionHostCount                       = $TargetSessionHostCount
        SessionHostNamePrefix                        = $SessionHostNamePrefix
        ADOrganizationalUnitPath                     = $ADOrganizationalUnitPath
        SubnetId                                     = $SubnetId
        SessionHostParameters                        = $SessionHostParameters.Parameters
        #UseAvailabilityZones                         = $UseAvailabilityZones
        Tags                                         = $Tags

        # Replacement plan template
        AllowDownsizing                              = $ReplacementPlanTemplate.AllowDownsizing
        AppPlanName                                  = $ReplacementPlanTemplate.AppPlanName
        AppPlanTier                                  = $ReplacementPlanTemplate.AppPlanTier
        DrainGracePeriodHours                        = $ReplacementPlanTemplate.DrainGracePeriodHours
        FixSessionHostTags                           = $ReplacementPlanTemplate.FixSessionHostTags
        FunctionAppZipUrl                            = $ReplacementPlanTemplate.FunctionAppZipUrl
        MaxSimultaneousDeployments                   = $ReplacementPlanTemplate.MaxSimultaneousDeployments
        ReplaceSessionHostOnNewImageVersion          = $ReplacementPlanTemplate.ReplaceSessionHostOnNewImageVersion
        ReplaceSessionHostOnNewImageVersionDelayDays = $ReplacementPlanTemplate.ReplaceSessionHostOnNewImageVersionDelayDays
        SessionHostInstanceNumberPadding             = $ReplacementPlanTemplate.SessionHostInstanceNumberPadding
        SHRDeploymentPrefix                          = $ReplacementPlanTemplate.SHRDeploymentPrefix
        TagDeployTimestamp                           = $ReplacementPlanTemplate.TagDeployTimestamp
        TagIncludeInAutomation                       = $ReplacementPlanTemplate.TagIncludeInAutomation
        TagPendingDrainTimestamp                     = $ReplacementPlanTemplate.TagPendingDrainTimestamp
        TagScalingPlanExclusionTag                   = $ReplacementPlanTemplate.TagScalingPlanExclusionTag
        TargetVMAgeDays                              = $ReplacementPlanTemplate.TargetVMAgeDays
        SessionHostTemplateUri                       = $ReplacementPlanTemplate.SessionHostTemplateUri
    }
}
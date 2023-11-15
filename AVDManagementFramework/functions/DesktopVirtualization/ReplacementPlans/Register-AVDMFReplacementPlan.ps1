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
        [string] $ScalingPlanExclusionTag = "ScalingPlanExclusion",

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $UniqueNameString = "",

        [PSCustomObject] $SessionHostParameters,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    $resourceName = New-AVDMFResourceName -ResourceType 'FunctionApp' -ParentName $HostPoolName -InstanceNumber 1 -UniqueNameString $UniqueNameString -NameSuffix $ReplacementPlanTemplate.ReplacementPlanNameSuffix
    $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/site/$ResourceName"

    $script:ReplacementPlans[$resourceName] = [PSCustomObject]@{
        ResourceGroupName                            = $ResourceGroupName
        HostPoolName                                 = $HostPoolName
        ResourceID                                   = $resourceID
        TargetSessionHostCount                       = $TargetSessionHostCount
        SessionHostNamePrefix                        = $SessionHostNamePrefix
        ADOrganizationalUnitPath                     = $ADOrganizationalUnitPath
        SubnetId                                     = $SubnetId
        SessionHostParameters                        = $SessionHostParameters.Parameters
        TagScalingPlanExclusionTag                   = $ScalingPlanExclusionTag
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
        TargetVMAgeDays                              = $ReplacementPlanTemplate.TargetVMAgeDays
        SessionHostTemplateUri                       = $ReplacementPlanTemplate.SessionHostTemplateUri
    }
}
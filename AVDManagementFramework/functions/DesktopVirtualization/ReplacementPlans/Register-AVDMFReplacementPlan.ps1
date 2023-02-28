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
        [int] $NumberOfSessionHosts,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $SessionHostNamePrefix,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [ValidateSet("AAD", "ADDS")]
        [string] $SessionHostJoinType = $script:SessionHostJoinType,

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
        NumberOfSessionHosts                         = $NumberOfSessionHosts
        SessionHostNamePrefix                        = $SessionHostNamePrefix
        SessionHostJoinType                          = $SessionHostJoinType
        ADOrganizationalUnitPath                     = $ADOrganizationalUnitPath
        SubnetId                                     = $SubnetId
        UseAvailabilityZones                         = $UseAvailabilityZones
        FunctionAppZipUrl                            = $ReplacementPlanTemplate.FunctionAppZipUrl
        AssignPermissions                            = $ReplacementPlanTemplate.AssignPermissions
        TagDeployTimestamp                           = $ReplacementPlanTemplate.TagDeployTimestamp
        TagIncludeInAutomation                       = $ReplacementPlanTemplate.TagIncludeInAutomation
        TagPendingDrainTimestamp                     = $ReplacementPlanTemplate.TagPendingDrainTimestamp
        TargetVMAgeDays                              = $ReplacementPlanTemplate.TargetVMAgeDays
        DrainGracePeriodHours                        = $ReplacementPlanTemplate.DrainGracePeriodHours
        FixSessionHostTags                           = $ReplacementPlanTemplate.FixSessionHostTags
        SHRDeploymentPrefix                          = $ReplacementPlanTemplate.SHRDeploymentPrefix
        MaxSimultaneousDeployments                   = $ReplacementPlanTemplate.MaxSimultaneousDeployments
        SessionHostTemplateUri                       = $ReplacementPlanTemplate.SessionHostTemplateUri
        #SessionHostTemplateParametersPS1Uri          = $ReplacementPlanTemplate.SessionHostTemplateParametersPS1Uri
        SessionHostParameters                        = $SessionHostParameters.Parameters
        SessionHostInstanceNumberPadding             = $ReplacementPlanTemplate.SessionHostInstanceNumberPadding
        ReplaceSessionHostOnNewImageVersion          = $ReplacementPlanTemplate.ReplaceSessionHostOnNewImageVersion
        ReplaceSessionHostOnNewImageVersionDelayDays = $ReplacementPlanTemplate.ReplaceSessionHostOnNewImageVersionDelayDays
        Tags                                         = $Tags
    }

}
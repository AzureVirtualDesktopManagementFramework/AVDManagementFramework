function Register-AVDMFScalingPlan {
    <#
    .SYNOPSIS
        This function registers a Scaling plan for a host pool.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ResourceGroupName,

        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $Location = $script:Location,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolName,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $HostPoolId,

        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [PSCustomObject] $ScalingPlanTemplate,

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )

    $resourceName = New-AVDMFResourceName -ResourceType 'ScalingPlan' -ParentName $HostPoolName -InstanceNumber 1

    $script:ScalingPlans[$resourceName] = [PSCustomObject]@{
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        HostPoolId        = $HostPoolId
        Timezone          = $ScalingPlanTemplate.Timezone
        Schedules         = $ScalingPlanTemplate.Schedules
        ExclusionTag      = $ScalingPlanTemplate.ExclusionTag
        Tags              = $Tags
    }
}
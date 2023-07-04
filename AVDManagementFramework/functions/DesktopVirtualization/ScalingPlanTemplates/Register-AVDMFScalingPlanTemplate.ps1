function Register-AVDMFScalingPlanTemplate {
    <#
    .SYNOPSIS
        This function registers a scaling plan template.

    .DESCRIPTION
        The Register-AVDMFScalingPlanTemplate function creates and registers a scaling plan template for Azure Virtual Desktop.
        It requires the time zone, schedules and a reference name as mandatory parameters.
        It also optionally allows for an exclusion tag and additional tags to be defined.

    .EXAMPLE
        Register-AVDMFScalingPlanTemplate -ReferenceName "MyTemplate" -Timezone "Pacific Standard Time" -Schedules @("Schedule1", "Schedule2")

    .NOTES
        The scaling plan template created by this function is stored in the ReplacementPlanTemplates array,
        using the provided reference name as the key.

    #>
    [CmdletBinding()]
    param (
        # The name of the scaling plan template to be registered. This will be used as the key in the ReplacementPlanTemplates array.
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string] $ReferenceName,

        # The time zone in which the scaling plan is to be implemented. Only accepts valid time zone names.
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [ValidateSet(
            ErrorMessage = 'Invalid Time Zone, Please use a valid Timezone from: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones',
            'Afghanistan Standard Time',
            'Arab Standard Time',
            'Arabian Standard Time',
            'Arabic Standard Time',
            'Argentina Standard Time',
            'Atlantic Standard Time',
            'AUS Eastern Standard Time',
            'Azerbaijan Standard Time',
            'Bangladesh Standard Time',
            'Belarus Standard Time',
            'Cape Verde Standard Time',
            'Caucasus Standard Time',
            'Central America Standard Time',
            'Central Asia Standard Time',
            'Central Europe Standard Time',
            'Central European Standard Time',
            'Central Pacific Standard Time',
            'Central Standard Time (Mexico)',
            'China Standard Time',
            'E. Africa Standard Time',
            'E. Europe Standard Time',
            'E. South America Standard Time',
            'Eastern Standard Time',
            'Egypt Standard Time',
            'Fiji Standard Time',
            'FLE Standard Time',
            'Georgian Standard Time',
            'GMT Standard Time',
            'Greenland Standard Time',
            'Greenwich Standard Time',
            'GTB Standard Time',
            'Hawaiian Standard Time',
            'India Standard Time',
            'Iran Standard Time',
            'Israel Standard Time',
            'Jordan Standard Time',
            'Korea Standard Time',
            'Mauritius Standard Time',
            'Middle East Standard Time',
            'Montevideo Standard Time',
            'Morocco Standard Time',
            'Mountain Standard Time',
            'Myanmar Standard Time',
            'Namibia Standard Time',
            'Nepal Standard Time',
            'New Zealand Standard Time',
            'Pacific SA Standard Time',
            'Pacific Standard Time',
            'Pakistan Standard Time',
            'Paraguay Standard Time',
            'Romance Standard Time',
            'Russian Standard Time',
            'SA Eastern Standard Time',
            'SA Pacific Standard Time',
            'SA Western Standard Time',
            'Samoa Standard Time',
            'SE Asia Standard Time',
            'Singapore Standard Time',
            'South Africa Standard Time',
            'Sri Lanka Standard Time',
            'Syria Standard Time',
            'Taipei Standard Time',
            'Tokyo Standard Time',
            'Tonga Standard Time',
            'Turkey Standard Time',
            'Ulaanbaatar Standard Time',
            'UTC',
            'UTC+12',
            'UTC-02',
            'UTC-11',
            'Venezuela Standard Time',
            'W. Central Africa Standard Time',
            'W. Europe Standard Time',
            'West Asia Standard Time',
            'West Pacific Standard Time'
        )]
        [string] $Timezone,

        # Array of schedule names that are associated with the scaling plan template.
        [Parameter(Mandatory = $true , ValueFromPipelineByPropertyName = $true )]
        [string[]] $Schedules,

        # Optional parameter. Defines a tag that, when assigned to a resource, will exclude it from the scaling plan.
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [string] $ExclusionTag = 'ScalingPlanExclusion',

        # Optional parameter. Defines a set of additional tags that will be assigned to the scaling plan template.
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName = $true )]
        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )

    [array] $scheduleArray = ($Schedules | ForEach-Object { $script:ScalingPlanScheduleTemplates[$_] }).Parameters

    $script:ScalingPlanTemplates[$ReferenceName] = [PSCustomObject]@{
        PSTypeName   = 'AVDMF.DesktopVirtualization.AVDScalingPlanTemplate'
        Timezone     = $Timezone
        Schedules    = $scheduleArray
        ExclusionTag = $ExclusionTag
        Tags         = $Tags
    }
}
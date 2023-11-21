function Initialize-AVDMFDesktopVirtualization {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]

    param (
        [string] $ResourceGroupName,
        [string] $ResourceCategory
    )
    switch ($ResourceCategory) {
        'HostPool' {
            $filteredHostPools = @{}
            $script:HostPools.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredHostPools.Add($_.Key, $_.Value) }

            $filteredApplicationGroups = @{}
            $script:ApplicationGroups.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredApplicationGroups.Add($_.Key, $_.Value) }

            $filteredRemoteApps = @{}
            $script:RemoteApps.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredRemoteApps.Add($_.Key, $_.Value) }
            if ($null -eq ([array] ($filteredRemoteApps | Convert-HashtableToArray))) {
                $filteredRemoteApps = @()
            }
            else {
                $filteredRemoteApps = [array] ($filteredRemoteApps | Convert-HashtableToArray)
            }

            $filteredReplacementPlans = @{}
            $script:ReplacementPlans.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredReplacementPlans.Add($_.Key, $_.Value) }

            $filteredScalingPlans = @{}
            $script:ScalingPlans.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredScalingPlans.Add($_.Key, $_.Value) }

            $filteredTemplateSpecs = @{}
            $script:TemplateSpecs.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredTemplateSpecs.Add($_.Key, $_.Value) }

            $templateParams = @{
                HostPools         = [array] ($filteredHostPools | Convert-HashtableToArray)
                ApplicationGroups = [array] ($filteredApplicationGroups | Convert-HashtableToArray)
                RemoteApps        = $filteredRemoteApps
                ScalingPlan       = if ($filteredScalingPlans.Keys.Count) { ([array] ($filteredScalingPlans | Convert-HashtableToArray))[0] } else { @{} } #TODO: There can only be one, review the code here.
                ReplacementPlan   = ([array] ($filteredReplacementPlans | Convert-HashtableToArray))[0] #TODO: There can only be one, review the code here.
                TemplateSpec      = ([array] ($filteredTemplateSpecs | Convert-HashtableToArray))[0]  #TODO: There can only be one, review the code here.
                ResourceGroupName = $ResourceGroupName
                Location          = $script:Location
            }
        }
        'Workspace' {
            $filteredWorkspaces = @{}
            $script:Workspaces.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredWorkspaces.Add($_.Key, $_.Value) }
            $templateParams = @{
                Workspaces = [array] ($filteredWorkspaces | Convert-HashtableToArray)
            }
        }
    }
    $templateParams
}
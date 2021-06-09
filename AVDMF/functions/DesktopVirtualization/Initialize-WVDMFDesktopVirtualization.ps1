function Initialize-WVDMFDesktopVirtualization {
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

            $filteredSessionHosts = @{}
            $script:SessionHosts.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } | ForEach-Object { $filteredSessionHosts.Add($_.Key, $_.Value) }

            $templateParams = @{
                HostPools         = [array] ($filteredHostPools | Convert-HashtableToArray)
                ApplicationGroups = [array] ($filteredApplicationGroups | Convert-HashtableToArray)
                SessionHosts      = [array] ($filteredSessionHosts | Convert-HashtableToArray)
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
function Invoke-AVDMFDesktopVirtualization {
    [CmdletBinding()]
    param (

    )

    #region: Initialize Variables

    $bicepWorkspaces = "$($moduleRoot)\internal\Bicep\DesktopVirtualization\Workspaces.bicep"
    $bicepHostPools = "$($moduleRoot)\internal\Bicep\DesktopVirtualization\HostPools.bicep"
    #endregion: Initialize Variables

    # Host Pools
    $hostPoolJobs = @()
    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'HostPool') {
            $templateParams = Initialize-AVDMFDesktopVirtualization -ResourceGroupName $rg -ResourceCategory 'HostPool'

            try {
                $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
            }
            catch {
                New-AzResourceGroup -Name $rg -Location $script:Location
            }
            $hostPoolJobs += New-AzSubscriptionDeployment -Location $script:Location -Name 'AVDMFHostPoolDeployment' -TemplateFile $bicepHostPools -TemplateParameterObject $templateParams
            #$hostPoolJobs += New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Incremental -TemplateFile $bicepHostPools @templateParams -ErrorAction Stop -Confirm:$false -Force -AsJob
            #TODO: We switched to incremental for the FunctionApp to take over host deployment. We need to add logic to remove RemoteApps, Application groups, that are no longer in configuration.

            #TODO: See if we can merge this into the main deployment


        }
        $dateTime = Get-Date
    }
    while ($hostPoolJobs.State -contains "Running") {
        Start-Sleep -Seconds 5
        $timeSpan = New-TimeSpan -Start $dateTime -End (Get-Date)
        $count = ($hostPoolJobs | Where-Object { $_.State -eq "Running" }).count
        Write-PSFMessage -Level Host -Message "Waiting for $count hostpool deployments to complete - Been waiting for $($timeSpan.ToString())"
    }
    Write-PSFMessage -Level Host -Message "Hostpool jobs completed."
    #$hostPoolJobs | Receive-Job

    #region: Update SessionDesktop name
    #TODO: Check if there is a put method yet for 'Microsoft.DesktopVirtualization/applicationgroups/desktops'
    foreach ($item in ($script:ApplicationGroups.GetEnumerator() |  Where-Object {$_.Value.ApplicationGroupType -eq 'Desktop'}) ) {
        Write-PSFMessage -Level Host -Message 'Updating SessionDesktop Friendly Name'
        $null = Update-AzWvdDesktop -ResourceGroupName $item.Value.ResourceGroupName -ApplicationGroupName $item.Key -Name 'SessionDesktop' -FriendlyName $item.Value.FriendlyName -ErrorAction Stop
    }
    #endregion

    # Workspaces
    Write-PSFMessage -Level Host -Message "Creating workspaces"
    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Workspace') {
            $templateParams = Initialize-AVDMFDesktopVirtualization -ResourceGroupName $rg -ResourceCategory 'Workspace'

            try {
                $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
            }
            catch {
                New-AzResourceGroup -Name $rg -Location $script:Location
            }
            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepWorkspaces @templateParams -ErrorAction Stop -Confirm:$false -Force
        }
    }

}
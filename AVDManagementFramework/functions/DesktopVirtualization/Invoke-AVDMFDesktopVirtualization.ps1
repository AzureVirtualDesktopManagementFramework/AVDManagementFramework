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

            try{
                $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
            }
            catch{
                New-AzResourceGroup -Name $rg -Location $script:Location
            }
            $hostPoolJobs += New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepHostPools @templateParams -ErrorAction Stop -Confirm:$false -Force -AsJob
        }
    }
    $dateTime = Get-Date
    while($hostPoolJobs.State -contains "Running"){
        Start-Sleep -Seconds 5
        $timeSpan = New-TimeSpan -Start $dateTime -End (Get-date)
        $count = ($hostPoolJobs | Where-Object {$_.State -eq "Running"}).count
        Write-PSFMessage -Level Host -Message "Waiting for $count hostpool deployments to complete - Been waiting for $($timeSpan.ToString())"
    }
    Write-PSFMessage -Level Host -Message "Hostpool jobs completed. See output below."
    $hostPoolJobs | Receive-Job

    # Workspaces
    Write-PSFMessage -Level Host -Message "Creating workspaces"
    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Workspace') {
            $templateParams = Initialize-AVDMFDesktopVirtualization -ResourceGroupName $rg -ResourceCategory 'Workspace'

            try{
                $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
            }
            catch{
                New-AzResourceGroup -Name $rg -Location $script:Location
            }
            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepWorkspaces @templateParams -ErrorAction Stop -Confirm:$false -Force
        }
    }

}
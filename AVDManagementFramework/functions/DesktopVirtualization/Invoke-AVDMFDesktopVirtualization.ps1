function Invoke-AVDMFDesktopVirtualization {
    [CmdletBinding()]
    param (

    )

    #region: Initialize Variables

    $bicepWorkspaces = "$($moduleRoot)\internal\Bicep\DesktopVirtualization\Workspaces.bicep"
    $bicepHostPools = "$($moduleRoot)\internal\Bicep\DesktopVirtualization\HostPools.bicep"
    #endregion: Initialize Variables

    # Host Pools

    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'HostPool') {
            $templateParams = Initialize-AVDMFDesktopVirtualization -ResourceGroupName $rg -ResourceCategory 'HostPool'

            try{
                $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
            }
            catch{
                New-AzResourceGroup -Name $rg -Location $script:Location
            }
            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepHostPools @templateParams -ErrorAction Stop -Confirm:$false -Force
        }
    }


    # Workspaces
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
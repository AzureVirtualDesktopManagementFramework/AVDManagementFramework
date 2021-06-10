function Test-AVDMFDesktopVirtualization {
    [CmdletBinding()]
    param (

    )

    #region: Initialize Variables
    $bicepHostPools = "$($moduleRoot)\internal\Bicep\DesktopVirtualization\HostPools.bicep"
    $bicepWorkspaces = "$($moduleRoot)\internal\Bicep\DesktopVirtualization\Workspaces.bicep"
    #endregion: Initialize Variables

    # Host Pools
    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'HostPool') {
            $templateParams = Initialize-AVDMFDesktopVirtualization -ResourceGroupName $rg -ResourceCategory 'HostPool'

            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepHostPools @templateParams -ErrorAction Stop -WhatIf
        }
    }
    # Workspaces
    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Workspace') {
            $templateParams = Initialize-AVDMFDesktopVirtualization -ResourceGroupName $rg -ResourceCategory 'Workspace'

            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepWorkspaces @templateParams -ErrorAction Stop -WhatIf
        }
    }
}
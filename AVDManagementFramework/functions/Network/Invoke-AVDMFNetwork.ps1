function Invoke-AVDMFNetwork {
    [CmdletBinding()]
    param (

    )

    #region: Initialize Variables
    $bicepVirtualNetwork = "$($moduleRoot)\internal\Bicep\Network\Network.bicep"
    #endregion: Initialize Variables

    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Network') {
            $templateParams = Initialize-AVDMFNetwork -ResourceGroupName $rg

            try{
                $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
            }
            catch{
                New-AzResourceGroup -Name $rg -Location $script:Location
            }

            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepVirtualNetwork @templateParams -ErrorAction Stop -Confirm:$false -Force
        }
    }
}
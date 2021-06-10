function Invoke-AVDMFStorage {
    [CmdletBinding()]
    param (

    )
    #region: Initialize Variables
    $bicepStorage = "$($moduleRoot)\internal\Bicep\Storage\Storage.bicep"
    #endregion: Initialize Variables

    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Storage') {
            $templateParams = Initialize-AVDMFStorage -ResourceGroupName $rg

            try{
                Get-AzResourceGroup -Name $rg -ErrorAction Stop | Out-Null
            }
            catch{
                New-AzResourceGroup -Name $rg -Location $script:Location
            }

            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Incremental -TemplateFile $bicepStorage @templateParams -ErrorAction Stop -Confirm:$false -Force
            # Cannot use Complete mode with Private links, see: https://feedback.azure.com/forums/217313-networking/suggestions/40395946-private-endpoint-arm-template-deployment-fix-comp

        }
    }
}
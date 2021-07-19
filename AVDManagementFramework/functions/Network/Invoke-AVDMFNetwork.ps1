function Invoke-AVDMFNetwork {
    [CmdletBinding()]
    param (

    )

    #Initialize Variables
    $bicepVirtualNetwork = "$($moduleRoot)\internal\Bicep\Network\Network.bicep"


    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Network') {
            $templateParams = Initialize-AVDMFNetwork -ResourceGroupName $rg
            $BP = 'HERE'
            try{
                $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
            }
            catch{
                New-AzResourceGroup -Name $rg -Location $script:Location
            }

            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepVirtualNetwork @templateParams -ErrorAction Stop -Confirm:$false -Force
        }
    }

    # Create remote peerings
    if($script:RemotePeerings.count){
        $bicepRemotePeerings = "$($moduleRoot)\internal\Bicep\Network\RemotePeerings.bicep"
        $templateParams =  Initialize-AVDMFRemotePeering
        New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $bicepRemotePeerings @templateParams -ErrorAction Stop -Confirm:$false -Force
    }


}
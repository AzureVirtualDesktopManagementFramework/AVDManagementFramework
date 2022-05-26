function Invoke-AVDMFNetwork {
    [CmdletBinding()]
    param (

    )

    #Initialize Variables
    $bicepVirtualNetwork = "$($moduleRoot)\internal\Bicep\Network\Network.bicep"


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

    # Create remote peerings
    if($script:RemotePeerings.count){
        # TODO: THERE IS A BUG HERE - need to ensure we change context to the right subscrtiption then back to the current one.
        $bicepRemotePeerings = "$($moduleRoot)\internal\Bicep\Network\RemotePeerings.bicep"
        $templateParams =  Initialize-AVDMFRemotePeering
        New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $bicepRemotePeerings @templateParams -ErrorAction Stop -Confirm:$false -Force
    }


}
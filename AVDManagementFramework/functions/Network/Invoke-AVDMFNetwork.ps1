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
        # TODO: THERE IS A BUG HERE - need to ensure we change context to the right subscription then back to the current one.

        $bicepRemotePeerings = "$($moduleRoot)\internal\Bicep\Network\RemotePeerings.bicep"
        $templateParams =  Initialize-AVDMFRemotePeering

        $currentSubscription = (Get-AzContext).Subscription.Id
        $targetSubscription = $templateParams.RemotePeerings.SubscriptionId

        Write-PSFMessage -Level Verbose -Message "Switching to remote network subscription context ({0})" -StringValues $targetSubscription
        $null = Set-AzContext -SubscriptionId  $templateParams.RemotePeerings.SubscriptionId

        # We are not using Azure Deployment for remote peering so we limit the needed permissions on the hub network
        # WE only need network contributor permissions on the hyb vNet using this approach.

        $remoteVNet = Get-AzVirtualNetwork -Name  $templateParams.RemotePeerings.RemoteVNetNAme -ResourceGroupName  $templateParams.RemotePeerings.ResourceGRoupName

        Add-AzVirtualNetworkPeering -Name $templateParams.RemotePeerings.Name -VirtualNetwork $remoteVNet -RemoteVirtualNetworkId  $templateParams.RemotePeerings.LocalVNetResourceId -ErrorAction Continue

        #New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $bicepRemotePeerings @templateParams -ErrorAction Stop -Confirm:$false -Force

        Write-PSFMessage -Level Verbose -Message "Switching back to local subscription context ({0})" -StringValues $targetSubscription
        $null = Set-AzContext -SubscriptionId  $currentSubscription
    }


}
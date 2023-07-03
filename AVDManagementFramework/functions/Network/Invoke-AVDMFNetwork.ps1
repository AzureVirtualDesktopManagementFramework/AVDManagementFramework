function Invoke-AVDMFNetwork {
    [CmdletBinding()]
    param (
        [ValidateSet('All', 'DeployNetwork', 'RemotePeering')]
        [string[]] $Action = 'All'
    )

    if ($Action -contains 'All' -or $Action -contains 'DeployNetwork') {
        Write-PSFMessage -Level Verbose -Message "Starting Action: DeployNetwork"
        # TODO: Handle multiple peerings scenario
        #Initialize Variables
        $bicepVirtualNetwork = "$($moduleRoot)\internal\Bicep\Network\Network.bicep"

        foreach ($rg in $script:ResourceGroups.Keys) {
            if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Network') {
                $templateParams = Initialize-AVDMFNetwork -ResourceGroupName $rg
                try {
                    Write-PSFMessage -Level Verbose -Message "Checking if resource group exists: {0}" -StringValues $rg
                    $null = Get-AzResourceGroup -Name $rg -ErrorAction Stop
                }
                catch {
                    Write-PSFMessage -Level Verbose -Message "Creating resource group {0} in Location {1}" -StringValues $rg, $script:Location #TODO: This is a repeated message and should use the power of PSFramework
                    New-AzResourceGroup -Name $rg -Location $script:Location
                }
                Write-PSFMessage -Level Verbose -Message "Deploying network resources in {0}" -StringValues $rg
                New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepVirtualNetwork @templateParams -ErrorAction Stop -Confirm:$false -Force
            }
        }
    }

    if ($Action -contains 'All' -or $Action -contains 'RemotePeering') {
        # Create remote peerings
        if ($script:RemotePeerings.count) {
            Write-PSFMessage -Level Verbose -Message "Starting Action: RemotePeering"

            $templateParams = Initialize-AVDMFRemotePeering

            $currentSubscription = (Get-AzContext).Subscription.Id
            $targetSubscription = $templateParams.RemotePeerings.SubscriptionId

            Write-PSFMessage -Level Verbose -Message "Switching to remote network subscription context ({0})" -StringValues $targetSubscription
            $null = Set-AzContext -SubscriptionId $templateParams.RemotePeerings.SubscriptionId

            # We are not using Azure Deployment for remote peering so we limit the needed permissions on the hub network
            # WE only need network contributor permissions on the hyb vNet using this approach.

            $remoteVNet = Get-AzVirtualNetwork -Name $templateParams.RemotePeerings.RemoteVNetNAme -ResourceGroupName $templateParams.RemotePeerings.ResourceGRoupName
            try{
                Add-AzVirtualNetworkPeering -Name $templateParams.RemotePeerings.Name -VirtualNetwork $remoteVNet -RemoteVirtualNetworkId $templateParams.RemotePeerings.LocalVNetResourceId -ErrorAction Stop
            }
            catch{
                if($_.Exception.Message -eq 'Peering with the specified name already exists'){
                    Write-PSFMessage -Level Warning -Message "Peering with the specified name already exists."
                }
                else{
                    $peeringError = $_
                }
            }
            finally{
                Write-PSFMessage -Level Verbose -Message "Switching back to local subscription context ({0})" -StringValues $targetSubscription
                $null = Set-AzContext -SubscriptionId $currentSubscription
                if($peeringError) {throw $peeringError}
            }
        }
    }
}
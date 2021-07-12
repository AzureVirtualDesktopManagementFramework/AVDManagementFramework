function Register-AVDMFVirtualNetwork {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $DNSServers,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [array] $DefaultSubnets,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [array] $VirtualNetworkPeerings,

        [string] $AccessLevel = 'All',
        [string] $HostPoolType = 'All',

        [PSCustomObject] $Tags = [PSCustomObject]@{}
    )
    process {
        $resourceName = New-AVDMFResourceName -ResourceType 'VirtualNetwork' -AccessLevel $AccessLevel -HostPoolType $HostPoolType

        #Register Resource Group if needed
        $resourceGroupName = New-AVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Network' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -InstanceNumber 1
        Register-AVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Network'
        # At the moment we do not have a reason for multiple network RGs.

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/VirtualNetworks/$resourceName"

        #Register Virtual Networks
        [string]$addressSpace = ($Script:AddressSpaces | Where-Object Scope -EQ 'VirtualNetwork').AddressSpace

        if (-not ($addressSpace -match '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/\d{2}$')) {
            throw "$addressSpace is not a valid address space"
        }

        # Configure Peerings
        $peerings = @(foreach($peering in $VirtualNetworkPeerings){
            $RemoteNetworkName = ($peering.RemoteVnetId -split "/")[-1]
            Write-PSFMessage -Level Verbose -Message "Configuring peering with $RemoteNetworkName"
            @{
                Name = "PeeringTo_$RemoteNetworkName"
                RemoteNetworkID = $peering.RemoteVnetId
                UseRemoteGateways = [bool] $peering.useRemoteGateways
            }
            if($peering.CreateRemotePeering){
                Write-PSFMessage -Level Verbose -Message "Registering remote peering."
                Register-AVDMFRemotePeering -RemoteVNetResourceID $peering.RemoteVNetId -LocalVNetResourceId $resourceID
            }
            else {
                Write-PSFMessage -Level Warning -Message "Peering of Virtual Network '$ReferenceName ($resourceName)' to '$RemoteNetworkName' is not configured to create remote peering. You must manually create peering in the remote network." # Add link to help on website.
            }
        })



        $script:VirtualNetworks[$ReferenceName] = [PSCustomObject]@{
            PSTypeName             = 'AVDMF.Network.VirtualNetwork'
            ResourceName           = $resourceName
            ResourceGroupName      = $resourceGroupName
            ResourceID             = $resourceID
            AddressSpace           = $addressSpace
            DNSServers             = $DNSServers
            VirtualNetworkPeerings = $peerings
            Tags = $Tags
        }

        #Register Default Subnets
        foreach ($subnet in $DefaultSubnets) {
            $subnet | Register-AVDMFSubnet -VirtualNetworkName $resourceName -VirtualNetworkID $resourceID -ErrorAction Stop
            #TODO Utilize value from pipeline of subnet object
        }
    }

}
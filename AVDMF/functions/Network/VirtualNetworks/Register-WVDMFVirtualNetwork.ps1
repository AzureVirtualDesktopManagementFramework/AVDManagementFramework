function Register-WVDMFVirtualNetwork {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $ReferenceName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [array] $AddressSpace,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $DNSServers,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [array] $DefaultSubnets,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [array] $VirtualNetworkPeerings,

        [string] $AccessLevel = 'All',
        [string] $HostPoolType = 'All'
    )
    process {
        $resourceName = New-WVDMFResourceName -ResourceType 'VirtualNetwork' -AccessLevel $AccessLevel -HostPoolType $HostPoolType

        #Register Resource Group if needed
        $resourceGroupName = New-WVDMFResourceName -ResourceType "ResourceGroup" -ResourceCategory 'Network' -AccessLevel $AccessLevel -HostPoolType $HostPoolType -InstanceNumber 1
        Register-WVDMFResourceGroup -Name $resourceGroupName -ResourceCategory 'Network'
        # At the moment we do not have a reason for multiple network RGs.

        $resourceID = "/Subscriptions/$script:AzSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/VirtualNetworks/$resourceName"

        #Register Virtual Networks
        [string]$addressSpace = ($Script:AddressSpaces | Where-Object Scope -EQ 'VirtualNetwork').AddressSpace

        if (-not ($addressSpace -match '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/\d{2}$')) {
            throw "$addressSpace is not a valid address space"
        }

        # Configure Peerings
        $peerings = @(foreach($peering in $VirtualNetworkPeerings){
            $RemoteNetworkName = ($peering -split "/")[-1]
            @{
                Name = "PeeringTo_$RemoteNetworkName"
                RemoteNetworkID = $peering
            }
        })

        $script:VirtualNetworks[$ReferenceName] = [PSCustomObject]@{
            PSTypeName             = 'WVDMF.Network.VirtualNetwork'
            ResourceName           = $resourceName
            ResourceGroupName      = $resourceGroupName
            ResourceID             = $resourceID
            AddressSpace           = $addressSpace
            DNSServers             = $DNSServers
            VirtualNetworkPeerings = $peerings
        }

        #Register Default Subnets
        foreach ($subnet in $DefaultSubnets) {
            $subnet | Register-WVDMFSubnet -VirtualNetworkName $resourceName -VirtualNetworkID $resourceID -ErrorAction Stop
            #TODO Utilize value from pipeline of subnet object
        }
    }

}
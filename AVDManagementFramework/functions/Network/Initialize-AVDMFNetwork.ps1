function Initialize-AVDMFNetwork {
    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable')]

    param (
        [string] $ResourceGroupName
    )

    $filteredVirtualNetworks = @{}
    $filteredSubnets = @{}
    $filteredNetworkSecurityGroups = @{}
    $filteredRouteTables = @{}


    $script:VirtualNetworks.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } -PipelineVariable vNet | ForEach-Object {
        $filteredVirtualNetworks.Add($vNet.Key, $vNet.Value)
        $script:Subnets.GetEnumerator() | Where-Object { $_.value.VirtualNetworkName -eq $vNet.Value.ResourceName } | ForEach-Object { $filteredSubnets.Add($_.Key, $_.Value) }
    }

    $script:RouteTables.GetEnumerator() | Where-Object { $_.value.ResourceGroupName -eq $ResourceGroupName } -PipelineVariable routeTable | ForEach-Object {
        $filteredRouteTables.Add($routeTable.Key, $routeTable.Value)
    }

    foreach ($nsg in $script:NetworkSecurityGroups.keys) {
        if ($script:NetworkSecurityGroups[$nsg].ResourceGroupName -eq $ResourceGroupName) {
            $filteredNetworkSecurityGroups[$nsg] = $script:NetworkSecurityGroups[$nsg]
        }
    }

    $templateParams = @{

        VirtualNetworks       = [array] ($filteredVirtualNetworks | Convert-HashtableToArray)
        Subnets               = [array] ($filteredSubnets | Convert-HashtableToArray)
        NetworkSecurityGroups = [array] ($filteredNetworkSecurityGroups | Convert-HashtableToArray)
        RouteTables           = [array] ($filteredRouteTables | Convert-HashtableToArray)

    }
    $templateParams

}
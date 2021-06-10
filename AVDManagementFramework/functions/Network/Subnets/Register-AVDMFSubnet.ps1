function Register-AVDMFSubnet {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Scope,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $NamePrefix,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $VirtualNetworkName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $VirtualNetworkID,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [bool] $PrivateLink = $false,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $NSGID ,


        [switch] $PassThru

    )

    process {
        #region: Calculate subnet range and prefix
        [array] $scope = ($Script:AddressSpaces | Where-Object { $_.Scope -eq $Scope })
        if ($scope.count -gt 1) { throw "Found multiple scopes, please review address spaces configuration and avoid duplicates." }

        [string] $addressSpace = $scope.AddressSpace
        [int] $subnetMask = $scope.SubnetMask
        Write-Verbose "Will use the address space $addressSpace and subnet mask $subnetMask"

        if (-not ($addressSpace -match '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/\d{2}$')) {
            throw "$addressSpace is not a valid address space"
        }

        $addressPrefix = (New-AVDMFSubnetRange -AddressSpace $addressSpace -NewSubnetMaskBits $subnetMask -ErrorAction 'Stop').AddressPrefix
        #endregion: Calculate subnet range and prefix

        $resourceName = New-AVDMFResourceName -ResourceType 'Subnet' -ParentName $NamePrefix -AddressPrefix $addressPrefix
        $resourceID = "$VirtualNetworkID/subnets/$resourceName"

        $script:Subnets[$resourceName] = [PSCustomObject]@{
            PSTypeName         = 'AVDMF.Network.Subnet'
            VirtualNetworkName = $VirtualNetworkName
            ResourceID         = $resourceID
            AddressPrefix      = $addressPrefix
            PrivateLink        = $PrivateLink
            NSGID              = $NSGID
        }

        if ($PassThru) { $resourceID }
    }

}
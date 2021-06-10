function New-AVDMFSubnetRange {
    [cmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '',Justification = "Does not change any states")]
    param(

        # Address Space for the subnet, this can be any of the address spaces created under the vNet in the format X.X.X.X/X
        [Parameter(Mandatory = $true)][string]$AddressSpace,

        # Mask bits of the new subnet, written as XX (example 27)
        [Parameter(Mandatory = $true)][int]$NewSubnetMaskBits

    )
    #region: functions
    function ConvertFrom-DecimalIPtoBinary ([string]$DecimalIPAddress) {
        #Create an empty variable
        $Binary = $null

        #Extract octets from IP Address
        $Octets = $DecimalIPAddress.Split('.')

        #Convert each octet to Binary and add to the variable $Binary
        # Here we use ToString with '2' as the base, 2 means binary
        # We are also using padleft to make sure each octet is 8 bits long with leading zeros if needed
        $Octets | ForEach-Object { $Binary += ([convert]::ToString($_, 2)).PadLeft(8, "0") }

        return $Binary
    }
    function ConvertFrom-BinaryIPtoDecimal ([string]$BinaryIPAddress) {
        #Create an empty string
        $Decimal = $null

        #Split Binary address into 4 octets - And convert to decimal
        # Again, 2 is for the base.
        $Octets = for ($i = 0; $i -lt 4; $i++) {
            [convert]::ToInt32($BinaryIPAddress.Substring($i * 8, 8), 2)
        }

        # Join the octets into one string with "." as delimeter
        $Decimal = $Octets -join "."

        return $Decimal
    }
    function Find-IPAddressesInRange ($FirstIPAddress, $LastIPAddress) {
        # First we confirm the IP Addresses to Binary, then to int64
        $Int64IP1 = [convert]::Toint64((ConvertFrom-DecimalIPtoBinary $FirstIPAddress), 2)
        $Int64IP2 = [convert]::Toint64((ConvertFrom-DecimalIPtoBinary $LastIPAddress), 2)

        # Then we just create a loop of all the values in the range of int64
        $IPAddresses = for ($i = $Int64IP1; $i -le $Int64IP2; $i++) {
            #Finally, we convert the int64 to binary then back to a decimal IP Address
            ConvertFrom-BinaryIPtoDecimal ([convert]::ToString($i, 2)).padleft(32, "0")
        }
        return $IPAddresses
    }
    function Get-SubnetDetails ($IPAddress, $MaskBits) {
        $BinaryIPAddress = ConvertFrom-DecimalIPtoBinary $IPAddress
        $SubnetID = ConvertFrom-BinaryIPtoDecimal $BinaryIPAddress.Substring(0, $MaskBits).PadRight(32, '0')
        $BroadcastIP = ConvertFrom-BinaryIPtoDecimal $BinaryIPAddress.Substring(0, $MaskBits).PadRight(32, '1')
        return [PSCustomObject]@{
            SubnetID      = $SubnetID
            BroadcastIP   = $BroadcastIP
            AddressPrefix = "$SubnetID/$MaskBits"
        }
    }
    function Test-OverlappingSubnets ($SubnetA, $SubnetB) {
        $SubnetAIDDigital = [convert]::Toint64((ConvertFrom-DecimalIPtoBinary $SubnetA.SubnetID), 2)
        $SubnetABCDigital = [convert]::Toint64((ConvertFrom-DecimalIPtoBinary $SubnetA.BroadcastIP), 2)

        $SubnetBIDDigital = [convert]::Toint64((ConvertFrom-DecimalIPtoBinary $SubnetB.SubnetID), 2)
        $SubnetBBCDigital = [convert]::Toint64((ConvertFrom-DecimalIPtoBinary $SubnetB.BroadcastIP), 2)

        if ($SubnetAIDDigital -ge $SubnetBIDDigital -and $SubnetAIDDigital -le $SubnetBBCDigital) { $Overlap = $true }
        elseif ($SubnetABCDigital -ge $SubnetBIDDigital -and $SubnetABCDigital -le $SubnetBBCDigital) { $Overlap = $true }
        else { $Overlap = $false }

        return $Overlap
    }
    #endregion: functions


    #region: Analyzing Address Space
    Write-Verbose -Message "Analyzing Address Space"
    #Find the position of '/' in the provided address space.
    $AddressSpaceIndexOfMaskBits = $AddressSpace.IndexOf("/")
    $AddressSpaceID = $AddressSpace.Substring(0, $AddressSpaceIndexOfMaskBits)
    $AddressSpaceMaskBits = $AddressSpace.Substring($AddressSpaceIndexOfMaskBits + 1)

    Write-Verbose -Message "ID: $AddressSpaceID - MaskbBits: $AddressSpaceMaskBits"


    $AddressSpaceSize = [math]::Pow(2, 32 - $AddressSpaceMaskBits)
    Write-Verbose -Message "Address Space Size: $AddressSpaceSize"


    Write-Verbose -Message "Finished Analyzing Address Space"
    #endregion: Analyzing Address Space

    #region: Find all possible subnets
    Write-Verbose -Message "ENTER: Find all possible subnets"

    $NewSubnetSize = [math]::Pow(2, (32 - $NewSubnetMaskBits))
    Write-Verbose -Message "New Subnet Size: $NewSubnetSize"

    $NumberOfPossibleSubnets = $AddressSpaceSize / $NewSubnetSize
    Write-Verbose -Message "Number of Possible Subnets: $NumberOfPossibleSubnets"

    $PossibleSubnetsArray = @(Get-SubnetDetails $AddressSpaceID $NewSubnetMaskBits)
    for ($i = 1; $i -lt $NumberOfPossibleSubnets; $i++) {
        $LastSubnetInt64 = ([convert]::Toint64((ConvertFrom-DecimalIPtoBinary $PossibleSubnetsArray[$i - 1].BroadcastIP), 2))
        $NextSubnetID = ConvertFrom-BinaryIPtoDecimal ([convert]::ToString($LastSubnetInt64 + 1, 2)).padleft(32, '0')

        $PossibleSubnetsArray += Get-SubnetDetails $NextSubnetID $NewSubnetMaskBits
    }

    Write-Verbose -Message "Calculated $($PossibleSubnetsArray.Count) possible subnets."

    Write-Verbose -Message "Exit: Find all possible subnets"
    #endregion: Find all possible subnets

    #region: Collect vNet information
    Write-Verbose -Message "ENTER: Collect vNet information"

    $vNetSubnets = foreach ($key in $script:Subnets.Keys) {
        if ((ConvertFrom-DecimalIPtoBinary ($script:Subnets[$key].AddressPrefix.Substring(0, $script:Subnets[$key].AddressPrefix.IndexOf("/")))).Substring(0, $AddressSpaceMaskBits) `
                -eq
            (ConvertFrom-DecimalIPtoBinary ($AddressSpaceID)).Substring(0, $AddressSpaceMaskBits)) {
            $script:Subnets[$key]
        }
    }

    Write-Verbose -Message "Found $($vNetSubnets.count) subnets in the vNet belonging to the address space $AddressSpace"

    $UtilizedAddressesArray = foreach ($Subnet in $vNetSubnets) {
        $IndexOfSubnetMask = $Subnet.AddressPrefix.indexOf("/")
        $SubnetID = $Subnet.AddressPrefix.Substring(0, $IndexOfSubnetMask)
        $MaskBits = $Subnet.AddressPrefix.Substring($IndexOfSubnetMask + 1)
        Get-SubnetDetails -IPAddress $SubnetID -MaskBits $MaskBits
    }


    Write-Verbose -Message "Calculated utilized addresses"

    Write-Verbose -Message "Exit: Collect vNet information"
    #endregion: Collect vNet information

    #region: Return the first free subnet
    Write-Verbose -Message "ENTER: Return the first free subnet"

    foreach ($PossibleSubnet in $PossibleSubnetsArray) {
        foreach ($ExistingSubnet in $UtilizedAddressesArray) {
            $Overlap = $false
            if (Test-OverlappingSubnets $PossibleSubnet $ExistingSubnet) {
                $Overlap = $true
                break
            }
        }
        if (!($Overlap)) { return $PossibleSubnet }
    }

    Write-Verbose -Message "Exit: Return the first free subnet"
    #endregion: Return the first free subnet

    # if we did not return any subnet, throw an error
    throw "Could not find any free subnets"

}
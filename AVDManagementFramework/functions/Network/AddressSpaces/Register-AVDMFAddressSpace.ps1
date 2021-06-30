function Register-AVDMFAddressSpace {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Scope,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $AddressSpace,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int] $SubnetMask
    )
    process {
        $Script:AddressSpaces += [PSCustomObject]@{
            Scope        = $Scope
            AddressSpace = $AddressSpace
            subnetMask   = $SubnetMask
        }
    }
}
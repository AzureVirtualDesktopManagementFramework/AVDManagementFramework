function Register-WVDMFAddressSpace {
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $DeploymentStage, #This has to be from the json file.

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Scope,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $AddressSpace,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int] $SubnetMask
    )
    process {
        #Register Address Space for the current deployment stage
        if($DeploymentStage -eq $script:DeploymentStage){ #TODO: Code Review usage of $script:DeploymentStage in this function.
            $Script:AddressSpaces += [PSCustomObject]@{
                DeploymentStage = $DeploymentStage
                Scope           = $Scope
                AddressSpace    = $AddressSpace
                subnetMask      = $SubnetMask
            }
        }
    }
}
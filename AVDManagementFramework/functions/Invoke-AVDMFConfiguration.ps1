function Invoke-AVDMFConfiguration {
    [CmdletBinding()]
    param (

    )

    # Create resource groups
    foreach ($rg in $script:ResourceGroups.Keys) {
        $newAzResourceGroup = @{
            Name = $rg
            Location = $script:Location
            Force = $true
        }
        if($script:ResourceGroups[$rg].Tags){
            $newAzResourceGroup['Tags'] = $script:ResourceGroups[$rg].Tags
        }
        New-AzResourceGroup @newAzResourceGroup
    }
    #TODO: Decide if we want to create RGs here or with deployment. decide on parallelism

    # Create network resources
    Invoke-AVDMFNetwork -ErrorAction Stop

    #Create storage resources
    Invoke-AVDMFStorage -ErrorAction Stop

    # Create Host Pools and Session Hosts
    Invoke-AVDMFDesktopVirtualization -ErrorAction Stop
}
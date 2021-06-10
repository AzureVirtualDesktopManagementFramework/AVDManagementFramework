function Invoke-AVDMFConfiguration {
    [CmdletBinding()]
    param (

    )

    # Create resource groups
    foreach ($rg in $script:ResourceGroups.Keys) {
        New-AzResourceGroup -Name $rg -Location $script:Location -Force
    }
    #TODO: Decide if we want to create RGs here or with deployment. decide on parallelism

    # Create network resources
    Invoke-AVDMFNetwork

    #Create storage resources
    Invoke-AVDMFStorage

    # Create Host Pools and Session Hosts
    Invoke-AVDMFDesktopVirtualization
}
function Invoke-WVDMFConfiguration {
    [CmdletBinding()]
    param (

    )

    # Create resource groups
    foreach ($rg in $script:ResourceGroups.Keys) {
        New-AzResourceGroup -Name $rg -Location $script:Location -Force
    }
    #TODO: Decide if we want to create RGs here or with deployment. decide on parallelism

    # Create network resources
    Invoke-WVDMFNetwork

    #Create storage resources
    Invoke-WVDMFStorage

    # Create Host Pools and Session Hosts
    Invoke-WVDMFDesktopVirtualization
}
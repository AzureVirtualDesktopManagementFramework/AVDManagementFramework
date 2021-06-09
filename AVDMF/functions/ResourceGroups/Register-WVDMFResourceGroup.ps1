function Register-WVDMFResourceGroup {
    [CmdletBinding()]
    param (

        [string] $Name,
        [string] $ResourceCategory
    )

    $script:ResourceGroups[$Name] = [PSCustomObject]@{
        PSTypeName  = 'WVDMF.ResourceGroup'
        ResourceCategory = $ResourceCategory
    }

}
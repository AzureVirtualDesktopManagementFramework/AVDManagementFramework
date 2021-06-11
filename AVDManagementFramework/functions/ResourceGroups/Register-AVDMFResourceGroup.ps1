function Register-AVDMFResourceGroup {
    [CmdletBinding()]
    param (
        [string] $Name,
        [string] $ResourceCategory
    )

    $script:ResourceGroups[$Name] = [PSCustomObject]@{
        PSTypeName  = 'AVDMF.ResourceGroup'
        ResourceCategory = $ResourceCategory
    }

}
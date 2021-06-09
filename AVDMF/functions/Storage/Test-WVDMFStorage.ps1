function Test-WVDMFStorage {
    [CmdletBinding()]
    param (

    )
    #region: Initialize Variables
    $bicepStorage = "$($moduleRoot)\internal\Bicep\Storage\Storage.bicep"
    #endregion: Initialize Variables

    foreach ($rg in $script:ResourceGroups.Keys) {
        if ($script:ResourceGroups[$rg].ResourceCategory -eq 'Storage') {
            $templateParams = Initialize-WVDMFStorage -ResourceGroupName $rg
            try{
                Get-AzResourceGroup -Name $rg -ErrorAction Stop | Out-Null
            }
            catch{
                Write-Warning -Message "Resourcegroup $rg does not exist. Skipping test for: `r`n$($templateParams.Values.ResourceID | out-string)"
                continue
            }
            New-AzResourceGroupDeployment -ResourceGroupName $rg -Mode Complete -TemplateFile $bicepStorage @templateParams -ErrorAction Stop -WhatIf
        }
    }
}
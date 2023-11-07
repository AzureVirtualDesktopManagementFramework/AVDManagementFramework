#region: Get latest Bicep version

#region: Install PowerShell Module path for artifact
    Install-Module -Name AVDManagementFramework -RequiredVersion 1.0.72 -Force -Confirm:$false -Scope AllUsers
    Import-Module -Name AVDManagementFramework
#endregion: Install PowerShell Module path for artifact

Set-AVDMFConfiguration -ConfigurationPath ".\$env:RELEASE_PRIMARYARTIFACTSOURCEALIAS\AVDMFConfiguration\ConfigurationFiles\"  -Verbose

Write-Output "Loaded AVD Configuration"

Invoke-AVDMFConfiguration

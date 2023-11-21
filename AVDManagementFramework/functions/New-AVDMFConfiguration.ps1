function New-AVDMFConfiguration {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Path = (Get-Location).Path,

        [switch] $Quiet
    )

    $modulePath = Split-Path -Path $MyInvocation.MyCommand.Module.Path
    $zipPath = Join-Path -Path $modulePath -ChildPath 'SampleConfiguration.zip'
    if(Test-Path -Path (Join-Path -Path $Path -ChildPath 'AVDMFConfiguration') -PathType Container){
        Stop-PSFFunction -Message "AVDMFConfiguration folder already exists. Please provide a different path." -EnableException $true -Category InvalidOperation
    }
    else{
        Expand-Archive -Path $zipPath -DestinationPath $Path -ErrorAction Stop
    }

    if(-Not $Quiet){
        $setPath = Join-PSFPath -Path $Path -Child 'AVDMFConfiguration','ConfigurationFiles'
        $newConfigurationWelcomeText = @"
Welcome To AVD Management Framework.

You just created a new configuration. The first step is to review the configuration and add users in the Host Pools.

You can deploy the configuration by running Set-AVDMFConfiguration -ConfigurationPath '$setPath' then Invoke-AVDMFConfiguration to create the resources in Azure.

Please make sure you connect to Azure using Add-AzAccount and Set-AzContext to your target subscription.

For more information please review the documentation. Happy AVD :)
"@
        Write-Host $newConfigurationWelcomeText -ForegroundColor Cyan
    }
}

function Set-WVDMFConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = "Does not change any states")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigurationPath,

        [string] $DeploymentStage, #TODO Remove default setting or use environment variable.
        [string] $AzSubscriptionId = (Get-AzContext).Subscription.Id,
        [switch] $Force
    )
    #region: Set DeploymentStage
    if ([string]::IsNullOrEmpty($DeploymentStage) -or [string]::IsNullOrWhiteSpace($DeploymentStage)) {
        throw "Deployment Stage is not defined, if running from local device use the -DeploymentStage parameter. Otherwise review environment variables."
        #TODO: Include environment variable name in error message.
    }
    $script:DeploymentStage = $DeploymentStage
    #endregion: Set DeploymentStage

    #region: Load Custom Environment Variables
    $environmentVariablesFilePath = Join-Path -Path $ConfigurationPath -ChildPath 'EnvironmentVariables.json'
    if(Test-Path -Path $environmentVariablesFilePath){
        write-warning -Message "EnvironmentVariables.json file detected. This is not supposed to exist on DevOps. Please add it to .gitignore"

        $environmentVariables = Get-Content -Path $environmentVariablesFilePath | ConvertFrom-Json | ConvertTo-PSFHashtable
        $null = $environmentVariables.GetEnumerator() | ForEach-Object {New-Item -Path $_.Key -Value $_.Value -Force}
    }
    #endregion: Load Custom Environment Variables

    #region: Register Name Mappings

        $nameMappingConfigPath = Join-Path -Path $ConfigurationPath -ChildPath "NameMappings"
        if (Test-Path $nameMappingConfigPath) {
            foreach ($file in Get-ChildItem -Path $nameMappingConfigPath -Filter "*.json") {
                foreach ($dataset in (Get-Content -Path $file.FullName | ConvertFrom-Json -ErrorAction Stop | ConvertTo-PSFHashtable )) {
                    Register-WVDMFNameMapping @dataset
                }
            }
        }
    #endregion: Register Name Mappings

    #region: Populate Script Variables
    $script:AzSubscriptionId = $AzSubscriptionId

    #endregion: Populate Script Variables


    if ($script:WVDConfigurationLoaded -and -not $Force) { throw "Configuration is already loaded. Use the force to reload." }
    if ($Force) { & "$moduleRoot\internal\scripts\variables.ps1" }

    #region: General Configuration
    $generalConfiguration = Get-Content -Path (Join-Path -Path $ConfigurationPath -ChildPath '\GeneralConfiguration\GeneralConfiguration.json' -ErrorAction Stop ) | ConvertFrom-Json -ErrorAction Stop
    $script:Location = $GeneralConfiguration.Location
    $script:TimeZone = $generalConfiguration.TimeZone
    $script:SessionHostPercentage = $generalConfiguration.sessionhostpercentage.$script:DeploymentStage
    $Script:DomainJoinUserName = $generalConfiguration.DomainJoinCredential.SecretName
    $Script:DomainJoinPassword = Get-AzKeyVaultSecret -ResourceId $generalConfiguration.DomainJoinCredential.KeyVaultID -Name $generalConfiguration.DomainJoinCredential.SecretName -AsPlainText
    <#
    $script:DomainJoinCredential = @{
            reference = @{
                keyVault = @{ id = $generalConfiguration.DomainJoinCredential.KeyVaultID}
                secretName = $generalConfiguration.DomainJoinCredential.SecretName
            }
    }
    #>
    #endregion

    #region: Naming Conventions
    $namingConventionsRoot = Join-Path -Path $ConfigurationPath -ChildPath NamingConventions

    $script:NamingStyles = Get-Content -Path $namingConventionsRoot\NamingStyles.json -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

    $namingConventionsComponentsRoot = Join-Path -Path $namingConventionsRoot -ChildPath "Components"

    foreach ($componentNC in (Get-ChildItem -Path $namingConventionsComponentsRoot -Filter "*.json")) {
        # We create a script variable for each component by adding 'NC' to the name of the file

        $NCContent = Get-Content -Path $componentNC.FullName -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        New-Variable -Scope 'script' -Name ("{0}NC" -f $componentNC.BaseName) -Value $NCContent
    }

    #endregion: Naming Conventions

    #region Network
    $networkFields = [ordered] @{
        'AddressSpaces'         = (Get-Command Register-WVDMFAddressSpace)
        'VirtualNetworks'       = (Get-Command Register-WVDMFVirtualNetwork)
        'NetworkSecurityGroups' = (Get-Command Register-WVDMFNetworkSecurityGroup)
    }
    foreach ($key in $networkFields.Keys) {
        $networkConfigPath = Join-Path -Path $ConfigurationPath -ChildPath "Network\$key"
        if (-not (Test-Path $networkConfigPath)) { continue }

        foreach ($file in Get-ChildItem -Path $networkConfigPath -Recurse -Filter "*.json") {
            foreach ($dataset in (Get-Content -Path $file.FullName | ConvertFrom-Json -ErrorAction Stop | ConvertTo-PSFHashtable)) {
                & $networkFields[$key] @dataset -ErrorAction Stop
            }
        }
    }
    #endregion Network

    #region Storage
    $storageFields = [ordered] @{
        'StorageAccounts' = (Get-Command Register-WVDMFStorageAccount)
        #'VirtualNetworks'       = (Get-Command Register-WVDMFVirtualNetwork)
        #'NetworkSecurityGroups' = (Get-Command Register-WVDMFNetworkSecurityGroup)
    }
    foreach ($key in $storageFields.Keys) {
        $storageConfigPath = Join-Path -Path $ConfigurationPath -ChildPath "Storage\$key"
        if (-not (Test-Path $storageConfigPath)) { continue }

        foreach ($file in Get-ChildItem -Path $storageConfigPath -Recurse -Filter "*.json") {
            foreach ($dataset in (Get-Content -Path $file.FullName | ConvertFrom-Json -ErrorAction Stop | ConvertTo-PSFHashtable)) {
                & $storageFields[$key] @dataset -ErrorAction Stop
            }
        }
    }
    #endregion Storage

    #region DesktopVirtualization
    $desktopVirtualizationFields = [ordered] @{
        'Workspaces'  = (Get-Command Register-WVDMFWorkspace)
        'VMTemplates' = (Get-Command Register-WVDMFVMTemplate)
        'HostPools'   = (Get-Command Register-WVDMFHostPool)
    }
    foreach ($key in $desktopVirtualizationFields.Keys) {
        $desktopVirtualizationConfigPath = Join-Path -Path $ConfigurationPath -ChildPath "DesktopVirtualization\$key"
        if (-not (Test-Path $desktopVirtualizationConfigPath)) { throw "No $key defined under $desktopVirtualizationConfigPath" }

        foreach ($file in Get-ChildItem -Path $desktopVirtualizationConfigPath -Recurse -Filter "*.json") {

            foreach ($dataset in (Get-Content -Path $file.FullName | ConvertFrom-Json -ErrorAction Stop | ConvertTo-PSFHashtable -Include $($desktopVirtualizationFields[$key].Parameters.Keys))) {
                foreach ($item in ($dataset.GetEnumerator() | Where-Object {$_.Value.GetType().Name -eq 'String'})){
                    $nameMappings = ([regex]::Matches($item.Value,'%.+?%')).Value | ForEach-Object {if($_) {$_ -replace "%",""}}
                    foreach ($mapping in $nameMappings){
                        $mappedValue = $script:NameMappings[$mapping]
                        $item.Value = $item.Value -replace "%$mapping%",$mappedValue
                    }
                    $dataset[$item.Key] = $item.Value
                }
                & $desktopVirtualizationFields[$key] @dataset -ErrorAction Stop
            }
        }
    }
    #endregion DesktopVirtualization


    $script:WVDConfigurationLoaded = $true
}
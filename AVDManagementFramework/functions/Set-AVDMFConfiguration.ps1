function Set-AVDMFConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = "Does not change any states")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigurationPath,

        [string] $AzSubscriptionId = (Get-AzContext).Subscription.Id,
        [switch] $Force

    )

    #region: Initialize Variables
    $configurationVersion = '1.0.57'
    #endregion: Initialize Variables

    #region: Load Custom Environment Variables
    $environmentVariablesFilePath = Join-Path -Path $ConfigurationPath -ChildPath 'EnvironmentVariables.jsonc'
    if (Test-Path -Path $environmentVariablesFilePath) {
        Write-PSFMessage -Level Warning -Message "EnvironmentVariables.json file detected. This is not supposed to exist on DevOps. Please add it to .gitignore"

        $environmentVariables = Get-Content -Path $environmentVariablesFilePath | ConvertFrom-Json | ConvertTo-PSFHashtable
        $null = $environmentVariables.GetEnumerator() | ForEach-Object { New-Item -Path $_.Key -Value $_.Value -Force }
    }
    #endregion: Load Custom Environment Variables
    #region: Set DeploymentStage
    $script:DeploymentStage = $env:SYSTEM_STAGEDISPLAYNAME
    if ([string]::IsNullOrEmpty($DeploymentStage) -or [string]::IsNullOrWhiteSpace($DeploymentStage)) {
        throw "Deployment Stage is not defined, if running from local device create EnvironmentVariables.json file. Otherwise review environment variables."
        #TODO: Include environment variable name in error message.
    }

    #endregion: Set DeploymentStage

    #region: Register Name Mappings

    $nameMappingConfigPath = Join-Path -Path $ConfigurationPath -ChildPath "NameMappings"
    if (Test-Path $nameMappingConfigPath) {
        foreach ($file in Get-ChildItem -Path $nameMappingConfigPath -filter "*.json*") {
            foreach ($dataset in (Get-Content -Path $file.FullName | ConvertFrom-Json -ErrorAction Stop | ConvertTo-PSFHashtable )) {
                Register-AVDMFNameMapping @dataset
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
    $generalConfiguration = Get-Content -Path (Join-Path -Path $ConfigurationPath -ChildPath '\GeneralConfiguration\GeneralConfiguration.jsonc' -ErrorAction Stop ) | ConvertFrom-Json -ErrorAction Stop

    if ($generalConfiguration.ConfigurationVersion -ne $configurationVersion) {
        throw "current configuration version $($generalConfiguration.ConfigurationVersion) must match $configurationVersion."
    }
    Write-PSFMessage -Message "Configuration version: {0}" -StringValues $configurationVersion

    $script:Location = $GeneralConfiguration.Location
    $script:TimeZone = $generalConfiguration.TimeZone

    # Azure AD or Domain Joined
    $script:SessionHostJoinType = $generalConfiguration.SessionHostJoinType
    switch ($script:SessionHostJoinType) {
        # AAD => Azure AD Joined Session Hosts
        "AAD" {
            #TODO: Build logic for Intune managed session hosts.
         }

        # ADDS => Domain Joined Session Hosts
        "ADDS" {
            $Script:DomainJoinUserName = $generalConfiguration.DomainJoinCredential.SecretName
            $Script:DomainJoinPassword = Get-AzKeyVaultSecret -ResourceId $generalConfiguration.DomainJoinCredential.KeyVaultID -Name $generalConfiguration.DomainJoinCredential.SecretName -AsPlainText

        }

        Default { throw "SessionHostJoin in GeneralConfiguration.jsonc must be ADDS or AAD "}
    }

    #endregion

    #region: Naming Conventions
    $namingConventionsRoot = Join-Path -Path $ConfigurationPath -ChildPath NamingConventions

    $script:NamingStyles = Get-Content -Path $namingConventionsRoot\NamingStyles.json -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

    $namingConventionsComponentsRoot = Join-Path -Path $namingConventionsRoot -ChildPath "Components"

    foreach ($componentNC in (Get-ChildItem -Path $namingConventionsComponentsRoot -filter "*.json*")) {
        # We create a script variable for each component by adding 'NC' to the name of the file

        $NCContent = Get-Content -Path $componentNC.FullName -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        New-Variable -Scope 'script' -Name ("{0}NC" -f $componentNC.BaseName) -Value $NCContent
    }

    #endregion: Naming Conventions

    #region: Define Registrable Components
    $components = [ordered] @{
        # Tags
        'GlobalTags'            = @{Command = (Get-Command -Name Register-AVDMFGlobalTag); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "GlobalTags") }
        # Network
        'AddressSpaces'         = @{Command = (Get-Command Register-AVDMFAddressSpace); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "Network\AddressSpaces") }
        'VirtualNetworks'       = @{Command = (Get-Command Register-AVDMFVirtualNetwork); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "Network\VirtualNetworks") }
        'RouteTables'           = @{Command = (Get-Command Register-AVDMFRouteTable); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "Network\RouteTables") }
        'NetworkSecurityGroups' = @{Command = (Get-Command Register-AVDMFNetworkSecurityGroup); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "Network\NetworkSecurityGroups") }
        # Storage
        'StorageAccounts'       = @{Command = (Get-Command Register-AVDMFStorageAccount); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "Storage\StorageAccounts") }
        # Desktop Virtualization
        'Workspaces'            = @{Command = (Get-Command Register-AVDMFWorkspace); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "DesktopVirtualization\Workspaces") }
        'VMTemplates'           = @{Command = (Get-Command Register-AVDMFVMTemplate); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "DesktopVirtualization\VMTemplates") }
        'RemoteAppTemplates'    = @{Command = (Get-Command Register-AVDMFRemoteAppTemplate); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "DesktopVirtualization\RemoteAppTemplates") }
        'HostPools'             = @{Command = (Get-Command Register-AVDMFHostPool); ConfigurationPath = (Join-Path -Path $ConfigurationPath -ChildPath "DesktopVirtualization\HostPools") }
    }
    #endregion: Define Registrable Components

    #region: Load Component Configuration
    foreach ($key in $components.Keys) {
        if (-not (Test-Path $components[$key].ConfigurationPath)) { continue }

        Write-PSFMessage -Level Verbose -Message "Loading configuration for $key"

        foreach ($file in Get-ChildItem -Path $components[$key].ConfigurationPath -Recurse -filter "*.json*") {
            Write-PSFMessage -Level Verbose -Message "`tLoading $key from $($file.FullName)"

            foreach ($dataset in (Get-Content -Path $file.FullName | ConvertFrom-Json -ErrorAction Stop | ConvertTo-PSFHashtable -Include $($components[$key].Command.Parameters.Keys))) {

                Write-PSFMessage -Level Verbose -Message "`t`tRegistering dataset:`r`n $($dataset | Format-List | Out-String -Width 120)"
                $dataset = Set-AVDMFNameMapping -Dataset $dataset
                $dataset = Set-AVDMFStageEntries -Dataset $dataset
                & $components[$key].Command @dataset -ErrorAction Stop
            }
        }
    }
    #endregion: Load Component Configuration

    #region: Add Tags
    $taggedResources = @(
        'ResourceGroup'
        'VirtualNetwork'
        'NetworkSecurityGroup'
        'RouteTable'
        'StorageAccount'
        'PrivateLink'
        'HostPool'
        'ApplicationGroup'
        'Workspace'
        'SessionHost'
    )
    foreach ($resourceType in $taggedResources) {
        $scriptVariable = Get-Variable -Scope script -Name "$($resourceType)s" -ValueOnly
        if (($script:GlobalTags.keys -contains $resourceType) -or ($script:GlobalTags.keys -contains 'All')) {
            $keys = [array] $scriptVariable.Keys
            foreach ($key in $keys) { $scriptVariable[$key] = Add-AVDMFTag -ResourceType $resourceType -ResourceObject $scriptVariable[$key] }
        }
    }

    #endregion: Add Tags

    $script:WVDConfigurationLoaded = $true
}
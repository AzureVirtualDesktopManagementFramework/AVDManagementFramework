# General Settings
$script:WVDConfigurationLoaded = $false
$script:NameMappings = @{}

# Resource Groups
$script:ResourceGroups = @{}

# Network
$script:VirtualNetworks = @{}
$script:Subnets = @{}
$Script:AddressSpaces = @()
$script:NetworkSecurityGroups = @{}
$script:RemotePeerings = @{}

# Storage
$script:StorageAccounts = @{}
$script:FileShares = @{}
$script:PrivateLinks = @{}

# DesktopVirtualization
$script:HostPools = @{}
$script:ApplicationGroups = @{}
$script:Workspaces = @{}
$script:VMTemplates = @{}
$script:SessionHosts = @{}

# Tags
$script:GlobalTags = @{}
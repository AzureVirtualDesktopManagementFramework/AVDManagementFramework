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
$script:RouteTables = @{}

# Storage
$script:StorageAccounts = @{}
$script:FileShares = @{}
$script:PrivateLinks = @{}

# DesktopVirtualization
$script:HostPools = @{}
$script:ApplicationGroups = @{}
$script:RemoteAppTemplates = @{}
$script:RemoteApps = @{}
$script:Workspaces = @{}
$script:VMTemplates = @{}
$script:SessionHosts = @{}
$script:ReplacementPlanTemplates = @{}
$script:ReplacementPlans= @{}
$script:ScalingPlanTemplates = @{}
$script:ScalingPlanScheduleTemplates = @{}
$script:ScalingPlans = @{}

# Tags
$script:GlobalTags = @{}
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
$script:FileShareAutoGrowLogicApps = @{}

# DesktopVirtualization
$script:HostPools = @{}
$script:ApplicationGroups = @{}
$script:RemoteAppTemplates = @{}
$script:RemoteApps = @{}
$script:Workspaces = @{}
$script:VMTemplates = @{}
$script:TemplateSpecs = @{} # We have one template spec created per host pool.
$script:SessionHosts = @{}
$script:ReplacementPlanTemplates = @{}
$script:ReplacementPlans = @{}
$script:ScalingPlanTemplates = @{}
$script:ScalingPlanScheduleTemplates = @{}
$script:ScalingPlans = @{}

# Tags
$script:GlobalTags = @{}
@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'AVDManagementFramework.psm1'

	# Version number of this module.
	ModuleVersion     = '1.0.0'

	# ID used to uniquely identify this module
	GUID              = '4f70498b-54a3-474a-b2e0-c8186ab8d4ed'

	# Author of this module
	Author            = 'Willy Moselhy'

	# Company or vendor of this module
	CompanyName       = 'Willy Moselhy'

	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2023 Willy Moselhy'

	# Description of the functionality provided by this module
	Description       = 'Azure Virtual Desktop Management Framework'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '7.0'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.9.0' }
		'Az.Accounts'
	)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\AVDManagementFramework.dll')

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\AVDManagementFramework.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\AVDManagementFramework.Format.ps1xml')

	# Functions to export from this module
	FunctionsToExport = @(
		'Invoke-AVDMFConfiguration'
		'Set-AVDMFConfiguration'
		'New-AVDMFConfiguration'
		'Register-AVDMFGlobalSettings'
		'Initialize-AVDMFNetwork'
		'Invoke-AVDMFNetwork'
		'Test-AVDMFNetwork'
		'Get-AVDMFAddressSpace'
		'Register-AVDMFAddressSpace'
		'Unregister-AVDMFAddressSpace'
		'Get-AVDMFNetworkSecurityGroup'
		'Register-AVDMFNetworkSecurityGroup'
		'Unregister-AVDMFNetworkSecurityGroup'
		'Get-AVDMFSubnet'
		'Register-AVDMFSubnet'
		'Unregister-AVDMFSubnet'
		'Get-AVDMFVirtualNetwork'
		'Register-AVDMFVirtualNetwork'
		'Unregister-AVDMFVirtualNetwork'
		'Get-AVDMFResourceGroup'
		'Invoke-AVDMFResourceGroup'
		'Register-AVDMFResourceGroup'
		'Test-AVDMFResourceGroup'
		'Unregister-AVDMFResourceGroup'
		'Initialize-AVDMFStorage'
		'Invoke-AVDMFStorage'
		'Test-AVDMFStorage'
		'Get-AVDMFFileShare'
		'Invoke-AVDMFFileShare'
		'Register-AVDMFFileShare'
		'Test-AVDMFFileShare'
		'Unregister-AVDMFFileShare'
		'Get-AVDMFPrivateLink'
		'Invoke-AVDMFPrivateLink'
		'Register-AVDMFPrivateLink'
		'Test-AVDMFPrivateLink'
		'Unregister-AVDMFPrivateLink'
		'Get-AVDMFStorageAccount'
		'Invoke-AVDMFStorageAccount'
		'Register-AVDMFStorageAccount'
		'Test-AVDMFStorageAccount'
		'Unregister-AVDMFStorageAccount'
		'New-AVDMFResourceName'
		'New-AVDMFSubnetRange'
		'Register-AVDMFHostPool'
		'Get-AVDMFHostPool'
		'Initialize-AVDMFDesktopVirtualization'
		'Invoke-AVDMFDesktopVirtualization'
		'Test-AVDMFDesktopVirtualization'
		'Get-AVDMFApplicationGroup'
		'Register-AVDMFApplicationGroup'
		'Get-AVDMFVMTemplate'
		'Get-AVDMFSessionHost'
		'Get-AVDMFNameMapping'
		'Get-AVDMFGlobalTag'
		'Get-AVDMFRemotePeering'
		'Get-AVDMFRouteTable'
		'Get-AVDMFRemoteAppTemplate'
		'Register-AVDMFRemoteAppTemplate'
		'Unregister-AVDMFRemoteAppTemplate'
		'Get-AVDMFRemoteApp'
		'Register-AVDMFRemoteApp'
		'Unregister-AVDMFRemoteApp'
		'Get-AVDMFWorkspace'
		'Get-AVDMFReplacementPlanTemplate'
		'Register-AVDMFReplacementPlanTemplate'
		'Get-AVDMFReplacementPlan'
		'Register-AVDMFReplacementPlan'
		'Get-AVDMFScalingPlanScheduleTemplate'
		'Register-AVDMFScalingPlanScheduleTemplate'
		'Get-AVDMFScalingPlanTemplate'
		'Register-AVDMFScalingPlanTemplate'
		'Get-AVDMFScalingPlan'
		'Register-AVDMFFileShareAutoGrowLogicApp'
		'Get-AVDMFFileShareAutoGrowLogicApp'
	)

	# Cmdlets to export from this module
	CmdletsToExport   = ''

	# Variables to export from this module
	VariablesToExport = ''

	# Aliases to export from this module
	AliasesToExport   = ''

	# List of all modules packaged with this module
	ModuleList        = @()

	# List of all files packaged with this module
	FileList          = @()

	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{

		#Support for PowerShellGet galleries.
		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()

			# A URL to the license for this module.
			# LicenseUri = ''

			# A URL to the main website for this project.
			# ProjectUri = ''

			# A URL to an icon representing this module.
			# IconUri = ''

			# ReleaseNotes of this module
			# ReleaseNotes = ''

		} # End of PSData hashtable

	} # End of PrivateData hashtable
}
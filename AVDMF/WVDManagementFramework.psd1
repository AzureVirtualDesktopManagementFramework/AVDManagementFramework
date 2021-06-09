@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'WVDManagementFramework.psm1'

	# Version number of this module.
	ModuleVersion     = '1.0.0'

	# ID used to uniquely identify this module
	GUID              = '4f70498b-54a3-474a-b2e0-c8186ab8d4ed'

	# Author of this module
	Author            = 'wmoselhy'

	# Company or vendor of this module
	CompanyName       = 'MyCompany'

	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2021 wmoselhy'

	# Description of the functionality provided by this module
	Description       = 'Windows Virtual Desktop Managemetn Framework'

	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'

	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.6.181' }
	)

	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\WVDManagementFramework.dll')

	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\WVDManagementFramework.Types.ps1xml')

	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\WVDManagementFramework.Format.ps1xml')

	# Functions to export from this module
	FunctionsToExport = @(
		'Invoke-WVDMFConfiguration'
		'Set-WVDMFConfiguration'
		'Register-WVDMFGlobalSettings'
		'Initialize-WVDMFNetwork'
		'Invoke-WVDMFNetwork'
		'Test-WVDMFNetwork'
		'Get-WVDMFAddressSpace'
		'Register-WVDMFAddressSpace'
		'Unregister-WVDMFAddressSpace'
		'Get-WVDMFNetworkSecurityGroup'
		'Register-WVDMFNetworkSecurityGroup'
		'Unregister-WVDMFNetworkSecurityGroup'
		'Get-WVDMFSubnet'
		'Register-WVDMFSubnet'
		'Unregister-WVDMFSubnet'
		'Get-WVDMFVirtualNetwork'
		'Register-WVDMFVirtualNetwork'
		'Unregister-WVDMFVirtualNetwork'
		'Get-WVDMFResourceGroup'
		'Invoke-WVDMFResourceGroup'
		'Register-WVDMFResourceGroup'
		'Test-WVDMFResourceGroup'
		'Unregister-WVDMFResourceGroup'
		'Initialize-WVDMFStorage'
		'Invoke-WVDMFStorage'
		'Test-WVDMFStorage'
		'Get-WVDMFFileShare'
		'Invoke-WVDMFFileShare'
		'Register-WVDMFFileShare'
		'Test-WVDMFFileShare'
		'Unregister-WVDMFFileShare'
		'Get-WVDMFPrivateLink'
		'Invoke-WVDMFPrivateLink'
		'Register-WVDMFPrivateLink'
		'Test-WVDMFPrivateLink'
		'Unregister-WVDMFPrivateLink'
		'Get-WVDMFStorageAccount'
		'Invoke-WVDMFStorageAccount'
		'Register-WVDMFStorageAccount'
		'Test-WVDMFStorageAccount'
		'Unregister-WVDMFStorageAccount'
		'New-WVDMFResourceName'
		'New-WVDMFSubnetRange'
		'Register-WVDMFHostPool'
		'Get-WVDMFHostPool'
		'Initialize-WVDMFDesktopVirtualization'
		'Invoke-WVDMFDesktopVirtualization'
		'Test-WVDMFDesktopVirtualization'
		'Get-WVDMFApplicationGroup'
		'Register-WVDMFApplicationGroup'
		'Get-WVDMFVMTemplate'
		'Get-WVDMFSessionHost'
		'Get-WVDMFNameMapping'

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
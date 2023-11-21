# AVDMF Sample Configuration
This is sample configuration for AVD Management Framework (AVDMF). It is intended to be used as a starting point for your own configuration.

# What is AVDMF?
AVDMF is a framework for deploying and managing Azure Virtual Desktop (AVD) environments. It is a set of PowerShell cmdlets and Bicep files. It parses a configuration that you create (similar to this sample) and
builds relationships between the different resources. You can also view what resources will be created and their configuration before invoking the deployment.

For example, when you configure a hostpool, AVDMF will link this pool to a dedicated subnet, create a file share for FSLogix, etc... You are able to customize the configuration to match your exact business needs.
You can use the same configuration to deploy multiple environments (dev, test, and prod for example)

The framework comes with a powerful name generator that is used to define the names of the resources. You can edit the sample configuration under `NamingConventions` folder to customize the naming of the resources.

# How to use this sample Configuration.

After installing the AVDMF PowerShell module (`Install-Module -Name AVDManagementFramework`), use the command `New-AVDMFConfiguration` to create a new configuration. This will create a folder with the configuration files. You can then edit the configuration files to match your needs.

Use this sample configuration as a starting point. It creates,
1. Three resource groups for Networking, Storage, and Workspace. And one resource group for each host pool.
2. Two host pools, one Full Desktop, the other is RemoteApp.
    - The session hosts are created from a sample Bicep file on GitHub. You can edit this file to match your needs and store in a Storage Account for example.
    - The session hosts are created and replaced automatically when there is a new update using AVD Replacement Plans.
3. One Storage Account, with a share for each host pool.
    - The storage account uses Azure Files Premium SKU. The default share is 100GB with automatic growth enabled to maintain 50GB of free space.
4. One Virtual Network with three subnets, one for each host pool and one for the storage account's private link.

Once you review the configuration, you can deploy it using the following steps,
1. Load the configuration into PowerShell using `Set-AVDMFConfiguration -Path <Path to your configuration folder>`
2. You can review the resources before deploying to azure using commands like `Get-AVDMFHostPool`
3. Deploy the configuration using `Invoke-AVDMFConfiguration`

# How to customize the configuration
You can update all the files as needed to add more host pools, change the naming convention, etc...
Here are a few examples to get you started,
- Assign users or groups to the host pools or RemoteApps. This is done from `DesktopVirtualization > HostPools > HostPool.jsonc`
  - AVDMF will then assign the users. If you are using Entra ID joined (The default in the sample) it will also assign the appropriate permissions for VM User Access.
- Add a peering to the virtual network. This is done from `Network > VirtualNetworks > Default.jsonc`


# What to do after deployment
You will need to take some manual steps that are not yet covered with AVDMF. For example, the NTFS settings for file shares are not added. This is only done once though, if you update the configuration and redeploy there is no need to redo these steps.

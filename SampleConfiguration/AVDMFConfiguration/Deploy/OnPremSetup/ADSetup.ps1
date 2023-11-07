#region: AD OUs

<#
    Main OU for AVD to host session hosts, storage accounts, Domain join accounts, and groups
    Hierarchy by Release pipeline and stage names then Host Pool Name
    - AVD (Root OU)
        - Development (release pipeline)
            - Development (stage)
                - RemoteApp01 (Host Pool)
        - Production (release pipeline)
            - Preview (stage)
            - GeneralAvailability (stage)
#>

#endregion

#region: Domain Join Account
<#
        This account is used during deployment to join session host VMs to domain.
        The username and password should be stored in Azure Key Vault and only accessed during deployment.
        The account requires delegation on the main AVD (Root OU) to create and delete computers.
#>
#endregion

#region: Security Groups
<#
    OU > AVD (root OU)
    AVD Computers:
        - Contains all session hosts. Used to exclude sessions hosts from upper level GPOs
        - Please update it after adding new sessions hosts.
    AVD Admins:
        - Has permissions on all AVD session hosts and Storage Accounts
    AVD Users:
        - Will only contain nested groups for Host pools (or Application Groups)
        - Has contribute permission on the storage accounts (Share and NTFS)

    Application group users
        - For each application group there should be a security group with all users who will access it.
        - Ideally, can be groups that are managed by MIM for automation.
#>
#endregion


#region: Group Policies
<#
    AVD-FSLogix Common Policy:
        - Target: AVD (root OU)
        - Description: ALL FSLogix Settings without ENABLE and PATH
        - SETTINGS:
            - FSLogix > Profile Containers
                - Profile type: Enabled - Normal direct-access profile
                - Dynamic VHD(X) allocation: Enabled
                - Delete local profile when FSLogix Profile should apply: Enabled
                - Prevent login with temporary profile: Enabled
                - Prevent login with failure: Enabled
                - Virtual disk type: Enabled - VHDX
                - Swap directory name components: Enabled
            - Computer > Policies > Windows Settings > Security Settings > Restricted Groups
                - Group: FSLogix Profile Exclude List
                - Members of this group: AVDAdmin (This is the built-in administrator name)
    AVD-Dev-RemoteApp01-FSLogix
        - Target: RemoteApp01 (Host pool)
        - Description: Enable FSLogix,  VHD location, and Size
        - Settings: FSLogix > Profile Containers
            - Enabled: Enabled
            - VHD location: \\avdsadev01.file.core.windows.net\avd-dev-hp-remoteapp-01\ProfileContainers
            - Size in MBs: 30000

#>
#endregion

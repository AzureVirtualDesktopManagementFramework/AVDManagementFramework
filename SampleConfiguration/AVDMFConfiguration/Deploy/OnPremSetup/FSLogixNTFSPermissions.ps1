# 1 - Join the storage account to AD using the steps here: https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable

# 2- Make sure you set the storage account for private link and block public access

# 3- Setup Share Permissions
#https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-assign-permissions?tabs=azure-powershell

$defaultPermission = "None|StorageFileDataSmbShareContributor|StorageFileDataSmbShareReader|StorageFileDataSmbShareElevatedContributor" # Set the default permission of your choice

$account = Set-AzStorageAccount -ResourceGroupName "<resource-group-name-here>" -AccountName "<storage-account-name-here>" -DefaultSharePermission $defaultPermission

$account.AzureFilesIdentityBasedAuth

# 4- Steps below


# We need to run this for each file share created. we have one file share per host pool.
# Reference: https://docs.microsoft.com/en-us/fslogix/fslogix-storage-config-ht

# Connect to the file share using the account key from Azure Portal

# Make sure you mount as the Z:\ Drive

# Create new folder
$AVDAdminsGroupName = "ORPIC\AVD Admins"

$folder = New-Item -Path Z:\ProfileContainers -ItemType Directory -Force

# Permissions
<#
    1- Disable inheritance
    2- AVD Admins => FULL CONTROL + Folder Owner
    3- Users => Modify this folder only
    4- Creator Owner => Modify subfolders and files
#>

$folderACL = Get-Acl -Path $folder.FullName

$ownerIdentityReference = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList $AVDAdminsGroupName

#Set Owner
$folderACL.SetOwner($ownerIdentityReference)

#Disable Inheritance
$folderACL.SetAccessRuleProtection($true,$false) # Disable inheritance AND remove existing permissions

$folderACL.Access

#Add new access rules
$folderACL.Access | ft

$creatorOwnerRule = New-Object -TypeName  System.Security.AccessControl.FileSystemAccessRule -ArgumentList ("CREATOR OWNER","Modify, Synchronize","ContainerInherit, ObjectInherit","InheritOnly","Allow")
$folderACL.AddAccessRule($creatorOwnerRule)

$usersRule = New-Object -TypeName  System.Security.AccessControl.FileSystemAccessRule -ArgumentList ("BUILTIN\Users","Modify, Synchronize","None","None","Allow")
$folderACL.AddAccessRule($usersRule)

$avdAdminsRule = New-Object -TypeName  System.Security.AccessControl.FileSystemAccessRule -ArgumentList ($ownerIdentityReference,"FullControl","ContainerInherit, ObjectInherit","None","Allow")
$folderACL.AddAccessRule($avdAdminsRule)

$systemRule = New-Object -TypeName  System.Security.AccessControl.FileSystemAccessRule -ArgumentList ("NT AUTHORITY\SYSTEM","FullControl","ContainerInherit, ObjectInherit","None","Allow")
$folderACL.AddAccessRule($systemRule)

# Apply new ACL
$folderACL | Set-Acl -Path $folder.FullName

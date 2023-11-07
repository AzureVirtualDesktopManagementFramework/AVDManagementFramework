$ServicePrincipalName = 'OQDevOps-AVD-ccd381c5-c25c-4727-9e11-016692204b61'
$HubNetworkSubscriptionId = 'dfad6942-7232-450c-a670-a1c36c92bfd5'
$HubNetworkResourceGroupName = 'rg-ALZ-HubNetworking-01'

# Owner on target subscription

# Graph API Directory.Read.All

# Reader on Resource Group where we have the Hub Network (for remote peering deployment)
# TODO: Check if this is needed when remote peering in different subscription bug is resolved.
Set-AzContext -SubscriptionId $HubNetworkSubscriptionId
$sp = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
New-AzRoleAssignment -ApplicationId $sp.AppId -RoleDefinitionName Reader -resourceGroup $HubNetworkResourceGroupName


# Network Contributor on hub network vnet resource


# Secrets Reader on Domain Join Account secret in Key Vault

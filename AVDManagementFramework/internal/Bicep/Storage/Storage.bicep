param StorageAccounts array
param PrivateLinks array
param FileShares array


module StorageAccountModule 'Modules/StorageAccount.bicep' = [for item in StorageAccounts: {
  name: item.Name
  params: {
    StorageAccountName: item.Name
    Location: resourceGroup().location
    Kind: item.Kind
    Sku: item.accountType
    SoftDeleteDays: item.SoftDeleteDays
    Tags: item.Tags
  }
}]

module PrivateLinkModule 'Modules/PrivateLink.bicep' = [for item in PrivateLinks: {
  name: item.Name
  params: {
    PrivateLinkName: item.Name
    Location: resourceGroup().location
    StorageAccountID: item.StorageAccountID
    SubnetID: item.SubnetID
    Tags: item.Tags
  }
  dependsOn: [
    StorageAccountModule
  ]
}]
module FileShareModule 'Modules/FileShare.bicep' = [for item in FileShares:{
  name: item.Name
  params:{
    FileShareName:item.Name
    StorageAccountName: item.StorageAccountName
  }
  dependsOn: [
    StorageAccountModule
  ]
}]

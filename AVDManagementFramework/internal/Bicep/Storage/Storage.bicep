param Location string = resourceGroup().location
param StorageAccounts array
param PrivateLinks array
param FileShares array


module StorageAccountModule 'Modules/StorageAccount.bicep' = [for item in StorageAccounts: {
  name: item.Name
  params: {
    StorageAccountName: item.Name
    Location: Location
    Kind: item.Kind
    Sku: item.accountType
    SoftDeleteDays: item.SoftDeleteDays
    DirectoryServiceOptions: item.DirectoryServiceOptions
    DomainName: item.DomainName
    DomainGuid: item.DomainGuid
    DefaultSharePermission: item.DefaultSharePermission
    Tags: item.Tags
  }
}]

module PrivateLinkModule 'Modules/PrivateLink.bicep' = [for item in PrivateLinks: {
  name: item.Name
  params: {
    PrivateLinkName: item.Name
    Location: Location
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

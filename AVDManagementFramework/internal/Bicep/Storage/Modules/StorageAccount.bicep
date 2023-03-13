param StorageAccountName string
param Location string
param Kind string = 'FileStorage'
param Sku string = 'Premium_LRS'
param SoftDeleteDays int
param Tags object = {}
param DirectoryServiceOptions string = 'None'
param DomainName string
param DomainGuid string
param DefaultSharePermission string = 'None'

resource StorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: StorageAccountName
  location: Location
  kind: Kind
  sku: {
    name: Sku
  }
  properties: {
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: DirectoryServiceOptions
      activeDirectoryProperties: {
        domainName: DomainName
        domainGuid: DomainGuid
      }
      defaultSharePermission: DefaultSharePermission
    }
  }
  resource FileServices 'fileServices' = {
    name: 'default'
    properties: {
      shareDeleteRetentionPolicy: {
        enabled: true
        days: SoftDeleteDays
      }
    }
  }
  tags: Tags
}

param StorageAccountName string
param Location string
param Kind string = 'FileStorage'
param Sku string = 'Premium_LRS'
param SoftDeleteDays int
param Tags object = {}

resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: StorageAccountName
  location: Location
  kind: Kind
  sku:{
    name:Sku
  }
  resource FileServices 'fileServices' ={
    name: 'default'
    properties:{
      shareDeleteRetentionPolicy: {
        enabled: true
        days: SoftDeleteDays
      }
    }
  }
  tags: Tags
}

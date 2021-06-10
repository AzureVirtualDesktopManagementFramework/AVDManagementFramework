param StorageAccountName string
param FileShareName string = 'test'

resource FileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01' = {
  name: '${StorageAccountName}/default/${FileShareName}'
  properties:{
    accessTier: 'Premium'
  }
}

param VMName string = 'TestVM'
param TimeStamp string = utcNow()


var VMPassword = 'P@ssw0rd1234' // uniqueString(TimeStamp)

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: VMName // Must be unique in AD and Azure RG
  location: 'eastus'
  properties:{
    storageProfile:{
      imageReference:{
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Office-365'
        sku: '20h2-evd-o365pp-g2'
        version: 'Latest'
      }
      osDisk :{
        name: '${VMName}-OSDisk'
        createOption:'FromImage'
        /*
        managedDisk:{
          storageAccountType:'Premium_LRS'
        }
        */
      }
    }
    osProfile:{
      computerName: 'BicepVM'
      adminUsername: 'AzureUser'
      adminPassword: VMPassword
    }
    hardwareProfile:{
      vmSize: 'Standard_B4ms'
    }
    networkProfile:{
      networkInterfaces: [
        {
          id: vNIC.id
        }
      ]
    }
  }
}
resource vNIC 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: concat(VMName,'-vNIC01')
  location: 'eastus'
  properties:{
    ipConfigurations:[
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet:{
            id: '/subscriptions/89f2b949-44fe-4969-9a1c-f53a85990a5d/resourceGroups/PFE_Labs/providers/Microsoft.Network/virtualNetworks/Labs_VNET_EUS/subnets/Subnet0'
          }
          publicIPAddress:{
            id: PublicIPAddress.id
          }
        }
      }
    ]
  }
}
resource PublicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: concat(VMName,'-pip01')
  location: 'eastus'
  properties:{
    publicIPAllocationMethod: 'Dynamic'
  }
}
resource InstallFSLogix 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${VMName}/InstallFSLogixUsingPowerShell'
  location: 'eastus'
  dependsOn: [
    vm
  ]
  properties:{
    publisher: 'Microsoft.compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings:{
      timestamp: 1 //This is used to force rerun, update value when we need to rerun the script on target VMs.
      CommandToExecute: 'Powershell.exe -ExecutionPolicy Unrestricted -File simple.ps1'
      fileuris: [
        'https://deletecounttimestamp.blob.core.windows.net/timestamp/simple.PS1?sp=r&st=2021-04-22T11:00:57Z&se=2021-04-23T19:00:57Z&spr=https&sv=2020-02-10&sr=b&sig=WrQALNKjdmh7%2BR3EApUoouXYCl6ZPLc5EEq%2F18Hok4c%3D'
      ]
    }
  }
}

output AdminAccountPassword string = VMPassword

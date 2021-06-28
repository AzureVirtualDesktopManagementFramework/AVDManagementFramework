param VMName string
param VMSize string
param TimeZone string
param Location string
param SubnetID string
param AdminUsername string
param Tags object = {}

@secure()
param AdminPassword string
param imageReference object

//HostPool join
param HostPoolName string
param HostPoolToken string
param WVDArtifactsURL string

//Domain Join
param DomainName string
param OUPath string
param DomainJoinUserName string

@secure()
param DomainJoinPassword string


resource vNIC 'Microsoft.Network/networkInterfaces@2020-11-01' ={
  name: '${VMName}-vNIC'
  location: Location
  properties:{
    ipConfigurations:[
      {
        name: 'ipconfig1'
        properties:{
          subnet:{
            id: SubnetID
          }
        }
      }
    ]
  }
  tags: Tags
}

resource VM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: VMName
  location:Location
  properties:{
    osProfile:{
      computerName:VMName
      adminUsername: AdminUsername
      adminPassword: AdminPassword
      windowsConfiguration:{
        timeZone: TimeZone
      }
    }
    hardwareProfile:{
      vmSize: VMSize
    }
    storageProfile:{
      osDisk:{
        name: '${VMName}-OSDisk'
        createOption: 'FromImage'
      }
      imageReference: imageReference
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: vNIC.id
        }
      ]
    }
  }
  tags: Tags
}

resource VMName_AddWVDHost 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  // Documentation is available here: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template
  // TODO: Update to the new format for DSC extension, see documentation above.
  name: '${VMName}/dscextension'
  location: Location
  properties:{
    publisher: 'Microsoft.PowerShell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: WVDArtifactsURL
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties:{
        hostPoolName: HostPoolName
        registrationInfoToken: HostPoolToken
      }
    }
  }
  dependsOn: [
    VMName_JoinDomain
  ]
}

resource VMName_JoinDomain 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  // Documentation is available here: https://docs.microsoft.com/en-us/azure/active-directory-domain-services/join-windows-vm-template#azure-resource-manager-template-overview
  name: '${VMName}/joindomain'
  location: Location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JSonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: DomainName
      OUPath: OUPath
      User: '${DomainName}\\${DomainJoinUserName}'
      Restart: 'true'

      //will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx'
      Options: 3
    }
    protectedSettings:{
      Password: DomainJoinPassword
    }
  }
  dependsOn:[
    VM
  ]
}

param VMName string
param VMSize string
param TimeZone string
param Location string
param SubnetID string
param AdminUsername string

param AvailabilityZone string

param AcceleratedNetworking bool

param Tags object = {}

@secure()
param AdminPassword string
param imageReference object

//HostPool join
param HostPoolName string
param HostPoolToken string
param WVDArtifactsURL string

// RunCommands
param PreJoinRunCommand array

//Domain Join
param JoinObject object


resource vNIC 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VMName}-vNIC'
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: SubnetID
          }
        }
      }
    ]
    enableAcceleratedNetworking: AcceleratedNetworking
  }
  tags: Tags
}

resource VM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: VMName
  location: Location
  identity: (JoinObject.SessionHostJoinType == 'AAD') ? { type: 'SystemAssigned' } : null
  zones: empty(AvailabilityZone) ? [] : [ '${AvailabilityZone}' ]
  properties: {
    osProfile: {
      computerName: VMName
      adminUsername: AdminUsername
      adminPassword: AdminPassword
      windowsConfiguration: {
        timeZone: TimeZone
      }
    }
    hardwareProfile: {
      vmSize: VMSize
    }
    storageProfile: {
      osDisk: {
        name: '${VMName}-OSDisk'
        createOption: 'FromImage'
      }
      imageReference: imageReference
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vNIC.id
        }
      ]
    }
    licenseType: 'Windows_Client'

  }
  resource amdGPUdrivers 'extensions@2022-08-01' = if (startsWith(VMSize, 'Standard_NV') && endsWith(VMSize, 'as_v4')) {
    // This is for AMD GPU enabled VMs in the family NVas_v4
    name: 'AMDGPUDriver'
    location: Location
    properties: {
      publisher: 'Microsoft.HpcCompute'
      type: 'AmdGpuDriverWindows'
      typeHandlerVersion: '1.1'
      autoUpgradeMinorVersion: true
      settings: {}
    }
  }
  // TODO: Drivers for Intel NVV3 VMs

  resource AADJoin 'extensions@2022-08-01' = if (JoinObject.SessionHostJoinType == 'AAD') {
    name: 'AADLoginForWindows'
    location: Location
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADLoginForWindows'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      settings: json('null') // TODO: Add support for intune managed. string in template is -  "settings": "[if(parameters('intune'), createObject('mdmId','0000000a-0000-0000-c000-000000000000'), json('null'))]"
    }
    dependsOn: startsWith(VMSize, 'Standard_NV') ? [ amdGPUdrivers ] : [] // TODO: Drivers for Intel NVV3 VMs
  }
  resource DomainJoin 'extensions@2022-08-01' = if (JoinObject.SessionHostJoinType == 'ADDS') {
    // Documentation is available here: https://docs.microsoft.com/en-us/azure/active-directory-domain-services/join-windows-vm-template#azure-resource-manager-template-overview
    name: 'DomainJoin'
    location: Location
    properties: {
      publisher: 'Microsoft.Compute'
      type: 'JSonADDomainExtension'
      typeHandlerVersion: '1.3'
      autoUpgradeMinorVersion: true
      settings: {
        Name: JoinObject.DomainName
        OUPath: JoinObject.OUPath
        User: '${JoinObject.DomainName}\\${JoinObject.DomainJoinUserName}'
        Restart: 'true'

        //will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx'
        Options: 3
      }
      protectedSettings: {
        Password: JoinObject.DomainJoinPassword
      }
    }
  }



  resource PreJoinCommand 'runCommands@2022-08-01' = [for (item, index) in PreJoinRunCommand: {
    name: 'PreJoinCommand${index+1}-${item.Name}'
    location: Location
    properties: {
      source: {
        scriptUri: item.ScriptURL
      }
    }
    dependsOn:  (JoinObject.SessionHostJoinType == 'AAD') ? [ AADJoin ] : [ DomainJoin ]
  }]
  /*
    resource importLocalGPO 'runCommands@2022-08-01' = {
    name: 'ImportLocalGPO4'
    location: Location
    properties: {
      source: {
        scriptUri: 'https://stcopdscdev2112.blob.core.windows.net/dsc/GPO/ImportLocalGPO.ps1'
      }
    }

    dependsOn: (JoinObject.SessionHostJoinType == 'AAD') ? [ AADJoin ] : [ DomainJoin ]
  }
  */
  resource AddWVDHost 'extensions@2022-08-01' = {
    // Documentation is available here: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template
    // TODO: Update to the new format for DSC extension, see documentation above.
    name: 'dscextension'
    location: Location
    properties: {
      publisher: 'Microsoft.PowerShell'
      type: 'DSC'
      typeHandlerVersion: '2.77'
      autoUpgradeMinorVersion: true
      settings: {
        modulesUrl: WVDArtifactsURL
        configurationFunction: 'Configuration.ps1\\AddSessionHost'
        properties: {
          hostPoolName: HostPoolName
          registrationInfoToken: HostPoolToken
          aadJoin: JoinObject.SessionHostJoinType == 'AAD' ? true : false
          useAgentDownloadEndpoint: true

        }
      }
    }
    dependsOn: [
      PreJoinCommand
    ]
  }

  tags: Tags
}

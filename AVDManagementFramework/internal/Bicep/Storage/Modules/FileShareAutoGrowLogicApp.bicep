param Location string = resourceGroup().location

param Name string
param StorageAccountId string
param TargetFreeSpaceGB int
param AllowShrink bool = true
param Enabled bool = true

var varStateValue = Enabled ? 'Enabled' : 'Disabled'

resource deployLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: Name
  location: Location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: varStateValue
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        AllowShrink: {
          defaultValue: AllowShrink
          type: 'Bool'
        }
        StorageAccoutIds: {
          defaultValue: [
            StorageAccountId
          ]
          type: 'Array'
        }
        TargetFreeSpaceGB: {
          defaultValue: TargetFreeSpaceGB
          type: 'Int'
        }
      }
      triggers: {
        'Recurrence_-_Daily': {
          recurrence: {
            frequency: 'Hour'
            interval: 1
            timeZone: 'GMT Standard Time'
          }
          evaluatedRecurrence: {
            frequency: 'Hour'
            interval: 1
            timeZone: 'GMT Standard Time'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        'Initialize_variable_-_File_Capacity': {
          runAfter: {
            'Initialize_variable_-_TargetFreeSpace': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'File Capacity'
                type: 'float'
                value: 0
              }
            ]
          }
        }
        'Initialize_variable_-_TargetFreeSpace': {
          runAfter: {}
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'TargetFreeSpace'
                type: 'float'
                value: '@mul(parameters(\'TargetFreeSpaceGB\'),1073741824)'
              }
            ]
          }
          description: 'Parameter * 1GB'
        }
        Process_for_each_Storage_Account_Id: {
          foreach: '@parameters(\'StorageAccoutIds\')'
          actions: {
            Get_List_of_File_Shares_in_Storage_Account: {
              runAfter: {}
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://management.azure.com/'
                  type: 'ManagedServiceIdentity'
                }
                method: 'GET'
                queries: {
                  'api-version': '2022-05-01'
                }
                uri: 'https://management.azure.com@{items(\'Process_for_each_Storage_Account_Id\')}/fileServices/default/shares'
              }
            }
            Parse_List_of_File_Shares: {
              runAfter: {
                Get_List_of_File_Shares_in_Storage_Account: [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'Get_List_of_File_Shares_in_Storage_Account\')'
                schema: {
                  properties: {
                    value: {
                      items: {
                        properties: {
                          etag: {
                            type: 'string'
                          }
                          id: {
                            type: 'string'
                          }
                          name: {
                            type: 'string'
                          }
                          properties: {
                            properties: {
                              accessTier: {
                                type: 'string'
                              }
                              enabledProtocols: {
                                type: 'string'
                              }
                              lastModifiedTime: {
                                type: 'string'
                              }
                              leaseState: {
                                type: 'string'
                              }
                              leaseStatus: {
                                type: 'string'
                              }
                              shareQuota: {
                                type: 'integer'
                              }
                            }
                            type: 'object'
                          }
                          type: {
                            type: 'string'
                          }
                        }
                        required: [
                          'id'
                          'name'
                          'type'
                          'etag'
                          'properties'
                        ]
                        type: 'object'
                      }
                      type: 'array'
                    }
                  }
                  type: 'object'
                }
              }
            }
            Process_for_each_File_Share: {
              foreach: '@body(\'Parse_List_of_File_Shares\')?[\'value\']'
              actions: {
                Condition: {
                  actions: {
                    Set_Quota_to_Calculated_Target_Quota: {
                      runAfter: {}
                      type: 'Http'
                      inputs: {
                        authentication: {
                          audience: 'https://management.azure.com/'
                          type: 'ManagedServiceIdentity'
                        }
                        body: {
                          properties: {
                            shareQuota: '@int(first(split(string(div(add(variables(\'File Capacity\'),variables(\'TargetFreeSpace\')),1073741824)),\'.\')))'
                          }
                        }
                        method: 'PATCH'
                        queries: {
                          'api-version': '2022-05-01'
                        }
                        uri: 'https://management.azure.com@{items(\'Process_for_each_Storage_Account_Id\')}/fileServices/default/shares/@{items(\'Process_for_each_File_Share\')?[\'name\']}'
                      }
                    }
                  }
                  runAfter: {
                    Extract_metric_value_from_parsed_JSON: [
                      'Succeeded'
                    ]
                  }
                  expression: {
                    or: [
                      {
                        greater: [
                          '@int(first(split(string(div(add(variables(\'File Capacity\'),variables(\'TargetFreeSpace\')),1073741824)),\'.\')))'
                          '@items(\'Process_for_each_File_Share\')?[\'properties\']?[\'shareQuota\']'
                        ]
                      }
                      {
                        and: [
                          {
                            less: [
                              '@int(first(split(string(div(add(variables(\'File Capacity\'),variables(\'TargetFreeSpace\')),1073741824)),\'.\')))'
                              '@items(\'Process_for_each_File_Share\')?[\'properties\']?[\'shareQuota\']'
                            ]
                          }
                          {
                            less: [
                              '@items(\'Process_for_each_File_Share\')?[\'properties\']?[\'lastModifiedTime\']'
                              '@addDays(utcNow(),-1)'
                            ]
                          }
                          {
                            equals: [
                              '@parameters(\'AllowShrink\')'
                              true
                            ]
                          }
                        ]
                      }
                    ]
                  }
                  type: 'If'
                }
                Extract_metric_value_from_parsed_JSON: {
                  foreach: '@body(\'Parse_File_Capacity_metric_value\')?[\'value\']'
                  actions: {
                    For_each_2: {
                      foreach: '@items(\'Extract_metric_value_from_parsed_JSON\')[\'timeseries\']'
                      actions: {
                        For_each_3: {
                          foreach: '@items(\'For_each_2\')[\'data\']'
                          actions: {
                            Set_variable: {
                              runAfter: {}
                              type: 'SetVariable'
                              inputs: {
                                name: 'File Capacity'
                                value: '@items(\'For_each_3\')?[\'average\']'
                              }
                            }
                          }
                          runAfter: {}
                          type: 'Foreach'
                        }
                      }
                      runAfter: {}
                      type: 'Foreach'
                    }
                  }
                  runAfter: {
                    Reset_File_Capacity_Variable: [
                      'Succeeded'
                    ]
                  }
                  type: 'Foreach'
                }
                Get_metric_File_Capacity_value_for_one_File_Share: {
                  runAfter: {}
                  type: 'Http'
                  inputs: {
                    authentication: {
                      audience: 'https://management.azure.com/'
                      type: 'ManagedServiceIdentity'
                    }
                    method: 'GET'
                    queries: {
                      '$filter': 'FileShare eq \'@{items(\'Process_for_each_File_Share\')?[\'name\']}\''
                      'api-version': '2019-07-01'
                    }
                    uri: 'https://management.azure.com@{items(\'Process_for_each_Storage_Account_Id\')}/fileServices/default/providers/Microsoft.Insights/metrics'
                  }
                }
                Parse_File_Capacity_metric_value: {
                  runAfter: {
                    Get_metric_File_Capacity_value_for_one_File_Share: [
                      'Succeeded'
                    ]
                  }
                  type: 'ParseJson'
                  inputs: {
                    content: '@body(\'Get_metric_File_Capacity_value_for_one_File_Share\')'
                    schema: {
                      properties: {
                        cost: {
                          type: 'integer'
                        }
                        interval: {
                          type: 'string'
                        }
                        namespace: {
                          type: 'string'
                        }
                        resourceregion: {
                          type: 'string'
                        }
                        timespan: {
                          type: 'string'
                        }
                        value: {
                          items: {
                            properties: {
                              displayDescription: {
                                type: 'string'
                              }
                              errorCode: {
                                type: 'string'
                              }
                              id: {
                                type: 'string'
                              }
                              name: {
                                properties: {
                                  localizedValue: {
                                    type: 'string'
                                  }
                                  value: {
                                    type: 'string'
                                  }
                                }
                                type: 'object'
                              }
                              timeseries: {
                                items: {
                                  properties: {
                                    data: {
                                      items: {
                                        properties: {
                                          average: {
                                            type: 'integer'
                                          }
                                          timeStamp: {
                                            type: 'string'
                                          }
                                        }
                                        required: [
                                          'timeStamp'
                                          'average'
                                        ]
                                        type: 'object'
                                      }
                                      type: 'array'
                                    }
                                    metadatavalues: {
                                      items: {
                                        properties: {
                                          name: {
                                            properties: {
                                              localizedValue: {
                                                type: 'string'
                                              }
                                              value: {
                                                type: 'string'
                                              }
                                            }
                                            type: 'object'
                                          }
                                          value: {
                                            type: 'string'
                                          }
                                        }
                                        required: [
                                          'name'
                                          'value'
                                        ]
                                        type: 'object'
                                      }
                                      type: 'array'
                                    }
                                  }
                                  required: [
                                    'metadatavalues'
                                    'data'
                                  ]
                                  type: 'object'
                                }
                                type: 'array'
                              }
                              type: {
                                type: 'string'
                              }
                              unit: {
                                type: 'string'
                              }
                            }
                            required: [
                              'id'
                              'type'
                              'name'
                              'displayDescription'
                              'unit'
                              'timeseries'
                              'errorCode'
                            ]
                            type: 'object'
                          }
                          type: 'array'
                        }
                      }
                      type: 'object'
                    }
                  }
                }
                Reset_File_Capacity_Variable: {
                  runAfter: {
                    Parse_File_Capacity_metric_value: [
                      'Succeeded'
                    ]
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'File Capacity'
                    value: 0
                  }
                }
              }
              runAfter: {
                Parse_List_of_File_Shares: [
                  'Succeeded'
                ]
              }
              type: 'Foreach'
            }
          }
          runAfter: {
            'Initialize_variable_-_File_Capacity': [
              'Succeeded'
            ]
          }
          type: 'Foreach'
          runtimeConfiguration: {
            concurrency: {
              repetitions: 1
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {}
  }
}

module RBACStorageAccountContributor '../../.Utilities/roleAssignment.bicep' = {
  name: 'RBACStorageAccountContributor'
  params: {
    PrinicpalId: deployLogicApp.identity.principalId
    RoleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
    Scope: StorageAccountId
  }
}

param batchsgName string
param location string = resourceGroup().location
param sku string
param kind string = 'StorageV2'
param tier string = 'Hot'
param queueName string = 'test01'
param containerName string = 'batch'
param peblobName string
param pequeueName string
param vnetName string
param subnetName string
param logicAppName string


//get exixting vnet
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
}

//storage account
resource batchstg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: batchsgName
  location: location
  kind: kind
  sku:{
    name:sku
  }
  properties:{
    accessTier: tier
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules:[
        {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnetName)
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

//container
resource batchcont 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${batchstg.name}/default/${containerName}'
  properties:{
    publicAccess: 'None'
  }
}

//queue
resource msgqueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2022-09-01' = {
  name: '${batchstg.name}/default/${queueName}'
}

//private endpoint blob
resource peblob 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: peblobName
  location: location
  properties:{
    privateLinkServiceConnections:[
      {
        name: peblobName
        properties:{
          privateLinkServiceId: batchstg.id
          groupIds: [
           'blob'
          ]
        }
      }
    ]
    customNetworkInterfaceName: '${peblobName}-nic'
    subnet:{
      id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnetName)
    }
  }
}

//private endpoint queue
resource pequeue 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: pequeueName
  location: location
  properties:{
    privateLinkServiceConnections:[
      {
        name: peblobName
        properties:{
          privateLinkServiceId: batchstg.id
          groupIds: [
           'queue'
          ]
        }
      }
    ]
    customNetworkInterfaceName: '${pequeueName}-nic'
    subnet:{
      id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnetName)
    }
  }
}

//existing logic app
resource logicAppRecource 'Microsoft.Web/sites@2022-03-01' existing = {
  name: logicAppName
}

//role
resource blobdataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}
resource queuedataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
}

//assign roles
resource roleAssignmentBlob 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id,blobdataContributor.id)
  properties: {
    principalId: logicAppRecource.identity.principalId
    roleDefinitionId: blobdataContributor.id
  }
}

resource roleAssignmentQueue 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id,queuedataContributor.id)
  properties: {
    principalId: logicAppRecource.identity.principalId
    roleDefinitionId: queuedataContributor.id
  }
}



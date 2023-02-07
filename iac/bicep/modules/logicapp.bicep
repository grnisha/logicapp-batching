param location string
param planName string
param logicAppName string
param vnetRuleName string
param vnetName string
param subnetName string
param planLocation string = resourceGroup().location
param planSku string ='WS1'
param planTier string = 'WorkflowStandard'
param sgName string
param sgsku string
param sgkind string = 'StorageV2'
param sgtier string = 'Hot'


//Create Storage
resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: sgName
  location: location
  kind: sgkind
  sku:{
    name:sgsku
  }
  properties:{
    accessTier: sgtier
  }
}

//Create app service plan
resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name:planName
  location:planLocation
  sku:{
    name:planSku
    tier:planTier
  }
}

//create logic app
resource logicAppRecource 'Microsoft.Web/sites@2022-03-01' = {
  name: logicAppName
  identity:{
    type:'SystemAssigned'    
  }
  location: location
  kind: 'functionapp,workflowapp'
  properties: {
    serverFarmId: asp.name
  }
}

//get exixting vnet
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
}
//vnet
resource vnetRule 'Microsoft.Web/sites/virtualNetworkConnections@2022-03-01' = {
  name: vnetRuleName
  parent: logicAppRecource
  properties: {
    vnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnetName)
    isSwift: true
  }
}


output logicAppName string = logicAppRecource.name
output logicAppTenantId string = logicAppRecource.identity.tenantId
output logicAppPrincipalId string = logicAppRecource.identity.principalId
output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${sgName};AccountKey=${stg.listKeys().keys[0].value};EndpointSuffix=core.windows.net'




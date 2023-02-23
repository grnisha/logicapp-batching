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
param office365ConName string = 'office365'


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
    vnetName: vnetRuleName
    vnetRouteAllEnabled: true
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnetName)
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

//connections
resource con 'Microsoft.Web/connections@2016-06-01' = {
  name: office365ConName
  location: location
  properties: {
    api: {
      name: office365ConName
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/uksouth/managedApis/${office365ConName}'
      displayName: 'Office 365 Outlook'
      description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organizations needs for robust security, reliability, and user productivity.'
      brandColor: '#0078D4'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1618/1.0.1618.3179/office365/icon.png'
      type:'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        method: 'get'
        requestUri:'https://management.azure.com:443/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${office365ConName}/extensions/proxy/testconnection?api-version=2016-06-01'
      }
    ]
  }
}

output logicAppName string = logicAppRecource.name
output logicAppTenantId string = logicAppRecource.identity.tenantId
output logicAppPrincipalId string = logicAppRecource.identity.principalId
output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${sgName};AccountKey=${stg.listKeys().keys[0].value};EndpointSuffix=core.windows.net'




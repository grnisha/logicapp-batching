param buildNumber string
param location string = resourceGroup().location
@minLength(3)
@maxLength(24)
@description('The name of the storage account')
param sgName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param sgsku string = 'Standard_LRS'

param logName string
param appInsName string
param vnetName string
param planName string
param planSku string
param planTier string
param logicAppName string


param appsgName string
param appsgsku string  = 'Standard_LRS'


var logicSubnetName = 'logic'
var storageSubnetName = 'storage'

// Log Analytics
module logAnalyticsModule 'modules/loganalytics.bicep' = {
  name: 'log-${buildNumber}'
  params: {
    name: logName
    location:location
  }
}
// Application insights
module appInsightsModule 'modules/appinsights.bicep' = {
  name:'appInsights-${buildNumber}'
  params:{
    name:appInsName
    rgLocation:location
    workspaceResourceId:logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

//VNet
module vnetModule 'modules/vnetwithsubnets.bicep' = {
  name: 'vnet-${buildNumber}'
  params: {
    vnetName: vnetName
    location: location
    logicSubnetName: logicSubnetName
    sgSubnetName: storageSubnetName
  }
}


  //Logic app
  module logicAppModule 'modules/logicapp.bicep' = {
    name: 'logic-${buildNumber}'
    params: {
      location: location
      logicAppName: logicAppName
      planName: planName
      sgName: sgName
      sgsku: sgsku
      subnetName: logicSubnetName
      vnetName: vnetName
      vnetRuleName: '${logicAppName}-rule'
      planSku: planSku
      planLocation: location
      planTier: planTier
    }
    dependsOn:[
      vnetModule
    ]
  }

  //App storage account
  module storageModule 'modules/storage.bicep' = {
    name: 'storage-${buildNumber}'
    params: {
      batchsgName: appsgName
      logicAppName: logicAppName
      peblobName: 'batch'
      pequeueName: 'int01'
      sku: appsgsku
      subnetName: storageSubnetName
      vnetName: vnetName
      location: location
    }
    dependsOn:[
      logicAppModule
    ]
  }

  // Logic app settings
module logicAppSettingsModule 'modules/logicappsettings.bicep' = {
  name: 'functionAppSettings-${buildNumber}'
  params: {
    appInsightsKey: appInsightsModule.outputs.appInsightsKey
    logicAppName: logicAppModule.outputs.logicAppName
    storageAccountConnectionString: logicAppModule.outputs.storageAccountConnectionString
    location: location
    appsgName: appsgName
  }  
  dependsOn:[
    logicAppModule
    appInsightsModule
    storageModule
  ]
}

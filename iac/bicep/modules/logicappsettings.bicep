param logicAppName string
param storageAccountConnectionString string
param appInsightsKey string
param region string = 'uksouth'
param location string = resourceGroup().location
param appsgName string


var appInsightsConnection = 'InstrumentationKey=${appInsightsKey};IngestionEndpoint=https://${region}-1.in.applicationinsights.azure.com/;LiveEndpoint=https://${region}.livediagnostics.monitor.azure.com/'

resource functionAppAppsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: '${logicAppName}/appsettings'
  properties: {
    APP_KIND: 'workflowApp'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnection
    AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
    AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
    AzureWebJobsStorage: storageAccountConnectionString
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'node'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
    WEBSITE_CONTENTSHARE: toLower(logicAppName)
    WEBSITE_NODE_DEFAULT_VERSION: '~14'
    WORKFLOWS_SUBSCRIPTION_ID: subscription().subscriptionId
    WORKFLOWS_LOCATION_NAME: location
    WORKFLOWS_RESOURCE_GROUP: resourceGroup().name
    queueServiceUri: 'https://${appsgName}.queue.core.windows.net/'
    batchBlobUri: 'https://${appsgName}.blob.core.windows.net/'
  }
}


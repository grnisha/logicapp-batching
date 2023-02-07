param name string
param location string = resourceGroup().location

resource log 'Microsoft.OperationalInsights/workspaces@2022-10-01'= {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output logAnalyticsWorkspaceId string = log.id

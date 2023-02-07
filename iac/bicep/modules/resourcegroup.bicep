targetScope = 'subscription'

@description('Name of the Resource Group to create')
param rgName string

@description('Location for the Resource Group')
param location string = 'uk south'

resource rgName_resource 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  name: rgName
  properties: {}
}

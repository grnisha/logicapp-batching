param vnetName string
param location string = resourceGroup().location
param logicSubnetName string = 'logic'
param sgSubnetName string = 'storage'
param vnetAddressPrefix string= '10.0.0.0/16'
param logicSubnetAddressPrefix string = '10.0.2.0/24'
param storageSubnetAddressPrefix string = '10.0.1.0/24'



resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [ 
      {
      name: sgSubnetName
      properties: {
        addressPrefix: storageSubnetAddressPrefix
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
            locations: [
              location
            ]
          }
        ]
        delegations: []
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      type: 'Microsoft.Network/virtualNetworks/subnets'
    }
    {
      name: logicSubnetName
      properties: {
        addressPrefix: logicSubnetAddressPrefix
        serviceEndpoints: []
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverfarms'
            }
            type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
          }
        ]
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      type: 'Microsoft.Network/virtualNetworks/subnets'
    }
  ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}




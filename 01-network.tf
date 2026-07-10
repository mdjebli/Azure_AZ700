###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : 01-network.tf
#
# Chapter     : Network Foundation
#
# Description :
#
# Création du socle réseau Azure :
#
#   - Resource Group réseau
#   - Hub VNet Australia East
#   - Subnets réservés aux services Azure
#
# Les services suivants seront ajoutés dans les chapitres
# suivants :
#
#   - Azure Firewall Premium
#   - VPN Gateway
#   - Azure Bastion
#   - Azure Route Server
#   - Private DNS Resolver
#
###############################################################


###############################################################
# Resource Group
#
# Le Resource Group est volontairement dédié à la couche réseau.
#
# Cette séparation permettra plus tard de gérer :
#
#   - réseau
#   - sécurité
#   - workloads
#   - monitoring
#
# indépendamment.
#
###############################################################

resource "azurerm_resource_group" "network" {

  name = local.resource_groups.network

  location = local.regions.primary

  tags = local.common_tags

}



###############################################################
# HUB VIRTUAL NETWORK
#
# Le Hub constitue le point central de connectivité.
#
# Il accueillera :
#
#   - VPN Gateway
#   - Azure Firewall
#   - Route Server
#   - Bastion
#   - Private DNS Resolver
#   - Private Endpoints
#
###############################################################

resource "azurerm_virtual_network" "hub" {

  name = local.virtual_networks.hub.name

  location = local.regions.primary

  resource_group_name = azurerm_resource_group.network.name


  address_space = local.virtual_networks.hub.address_space


  tags = local.common_tags

}



###############################################################
# VPN Gateway subnet
#
# IMPORTANT :
#
# Le nom GatewaySubnet est imposé par Azure.
#
# Aucun préfixe "snet-" ne doit être ajouté.
#
# Taille recommandée : /27 minimum.
#
###############################################################

resource "azurerm_subnet" "gateway" {

  name = local.hub_subnets.gateway.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.gateway.prefix
  ]

}



###############################################################
# Azure Firewall subnet
#
# IMPORTANT :
#
# Le nom AzureFirewallSubnet est imposé par Azure.
#
# Taille minimale : /26.
#
###############################################################

resource "azurerm_subnet" "firewall" {

  name = local.hub_subnets.firewall.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.firewall.prefix
  ]

}



###############################################################
# Azure Firewall Management subnet
#
# Utilisé avec Azure Firewall Premium en mode
# Forced Tunneling.
#
# Taille minimale : /26.
#
###############################################################

resource "azurerm_subnet" "firewall_management" {

  name = local.hub_subnets.firewall_management.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.firewall_management.prefix
  ]

}

###############################################################
# Azure Bastion subnet
#
# IMPORTANT :
#
# Le nom AzureBastionSubnet est imposé par Azure.
#
# Ce subnet accueillera ultérieurement le service Bastion.
#
# Taille minimale recommandée : /26
#
###############################################################

resource "azurerm_subnet" "bastion" {

  name = local.hub_subnets.bastion.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.bastion.prefix
  ]

}



###############################################################
# Azure Route Server subnet
#
# IMPORTANT :
#
# Le nom RouteServerSubnet est imposé par Azure.
#
# Ce subnet sera utilisé dans le futur chapitre BGP :
#
#   - Azure Route Server
#   - échanges de routes dynamiques
#   - appliances réseau virtuelles
#
# Taille minimale : /27
#
###############################################################

resource "azurerm_subnet" "route_server" {

  name = local.hub_subnets.route_server.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.route_server.prefix
  ]

}



###############################################################
# Private DNS Resolver - Inbound Endpoint subnet
#
# Le Private DNS Resolver utilise deux subnets dédiés :
#
#   - inbound
#   - outbound
#
# Ces subnets ne peuvent pas être utilisés par d'autres
# ressources.
#
# Taille minimale : /28
#
###############################################################

resource "azurerm_subnet" "dns_inbound" {

  name = local.hub_subnets.dns_inbound.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.dns_inbound.prefix
  ]


}



###############################################################
# Private DNS Resolver - Outbound Endpoint subnet
#
###############################################################

resource "azurerm_subnet" "dns_outbound" {

  name = local.hub_subnets.dns_outbound.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.dns_outbound.prefix
  ]

}



###############################################################
# Private Endpoints subnet
#
# Tous les Private Endpoints du laboratoire seront regroupés
# ici.
#
# Le réseau sera utilisé plus tard pour :
#
#   - Storage Account
#   - Azure SQL
#   - Key Vault
#   - autres services PaaS
#
# Les network policies doivent être désactivées afin de
# permettre le fonctionnement correct des Private Endpoints.
#
###############################################################

resource "azurerm_subnet" "private_endpoints" {

  name = local.hub_subnets.private_endpoints.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  address_prefixes = [
    local.hub_subnets.private_endpoints.prefix
  ]


  private_endpoint_network_policies = "Disabled"

}


###############################################################
#
# SPOKE WORKLOAD
#
# Région :
#
#   Australia East
#
# Ce réseau hébergera les charges applicatives.
#
# Il sera connecté au Hub par peering dans le fichier :
#
#   02-network-peering.tf
#
# Subnets prévus :
#
#   - Frontend
#   - Backend
#
###############################################################

resource "azurerm_virtual_network" "workload" {

  name = local.virtual_networks.workload.name


  location = local.regions.primary


  resource_group_name = azurerm_resource_group.network.name


  address_space = local.virtual_networks.workload.address_space


  tags = local.common_tags

}



###############################################################
# Workload Frontend subnet
#
# Exemple d'utilisation future :
#
#   - Web servers
#   - Application Gateway backend pool
#   - Load Balancer frontend
#
###############################################################

resource "azurerm_subnet" "frontend" {

  name = local.workload_subnets.frontend.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.workload.name


  address_prefixes = [
    local.workload_subnets.frontend.prefix
  ]

}



###############################################################
# Workload Backend subnet
#
# Exemple d'utilisation future :
#
#   - Application servers
#   - API services
#   - Internal workloads
#
###############################################################

resource "azurerm_subnet" "backend" {

  name = local.workload_subnets.backend.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.workload.name


  address_prefixes = [
    local.workload_subnets.backend.prefix
  ]

}



###############################################################
#
# SPOKE DISASTER RECOVERY
#
# Région :
#
#   East Asia
#
# Ce réseau représente le site secondaire.
#
# Il servira pour démontrer :
#
#   - architecture multi-région
#   - reprise après sinistre
#   - routage inter-régions
#
###############################################################

resource "azurerm_virtual_network" "dr" {

  name = local.virtual_networks.disaster_recovery.name


  location = local.regions.disaster_recovery


  resource_group_name = azurerm_resource_group.network.name


  address_space = local.virtual_networks.disaster_recovery.address_space


  tags = local.common_tags

}



###############################################################
# DR Frontend subnet
#
###############################################################

resource "azurerm_subnet" "dr_frontend" {

  name = local.dr_subnets.frontend.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.dr.name


  address_prefixes = [
    local.dr_subnets.frontend.prefix
  ]

}



###############################################################
# DR Backend subnet
#
###############################################################

resource "azurerm_subnet" "dr_backend" {

  name = local.dr_subnets.backend.name


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.dr.name


  address_prefixes = [
    local.dr_subnets.backend.prefix
  ]

}

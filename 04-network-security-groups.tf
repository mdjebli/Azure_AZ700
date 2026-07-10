###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : 04-network-security-groups.tf
#
# Chapter     : Network Security Groups
#
# Description :
#
# Création des frontières de sécurité réseau pour les
# subnets applicatifs.
#
# Les règles de sécurité spécifiques seront ajoutées dans
# les chapitres dédiés aux workloads.
#
# Subnets concernés :
#
#   Australia East
#       - workload frontend
#       - workload backend
#
#   East Asia
#       - DR frontend
#       - DR backend
#
#
# Les subnets Azure réservés aux services plateforme ne
# reçoivent volontairement pas de NSG :
#
#   - GatewaySubnet
#   - AzureFirewallSubnet
#   - AzureFirewallManagementSubnet
#   - AzureBastionSubnet
#   - RouteServerSubnet
#
###############################################################


###############################################################
#
# WORKLOAD FRONTEND NSG
#
###############################################################

resource "azurerm_network_security_group" "workload_frontend" {

  name                = "nsg-aue-workload-frontend"
  location            = local.regions.primary
  resource_group_name = azurerm_resource_group.network.name


  tags = local.common_tags

}



###############################################################
#
# WORKLOAD BACKEND NSG
#
###############################################################

resource "azurerm_network_security_group" "workload_backend" {

  name                = "nsg-aue-workload-backend"
  location            = local.regions.primary
  resource_group_name = azurerm_resource_group.network.name


  tags = local.common_tags

}



###############################################################
#
# DR FRONTEND NSG
#
###############################################################

resource "azurerm_network_security_group" "dr_frontend" {

  name                = "nsg-eas-dr-frontend"
  location            = local.regions.disaster_recovery
  resource_group_name = azurerm_resource_group.network.name


  tags = local.common_tags

}



###############################################################
#
# DR BACKEND NSG
#
###############################################################

resource "azurerm_network_security_group" "dr_backend" {

  name                = "nsg-eas-dr-backend"
  location            = local.regions.disaster_recovery
  resource_group_name = azurerm_resource_group.network.name


  tags = local.common_tags

}



###############################################################
#
# ASSOCIATION
#
# WORKLOAD FRONTEND SUBNET
#
###############################################################

resource "azurerm_subnet_network_security_group_association" "workload_frontend" {

  subnet_id = azurerm_subnet.frontend.id

  network_security_group_id = azurerm_network_security_group.workload_frontend.id

}



###############################################################
#
# ASSOCIATION
#
# WORKLOAD BACKEND SUBNET
#
###############################################################

resource "azurerm_subnet_network_security_group_association" "workload_backend" {

  subnet_id = azurerm_subnet.backend.id

  network_security_group_id = azurerm_network_security_group.workload_backend.id

}



###############################################################
#
# ASSOCIATION
#
# DR FRONTEND SUBNET
#
###############################################################

resource "azurerm_subnet_network_security_group_association" "dr_frontend" {

  subnet_id = azurerm_subnet.dr_frontend.id

  network_security_group_id = azurerm_network_security_group.dr_frontend.id

}



###############################################################
#
# ASSOCIATION
#
# DR BACKEND SUBNET
#
###############################################################

resource "azurerm_subnet_network_security_group_association" "dr_backend" {

  subnet_id = azurerm_subnet.dr_backend.id

  network_security_group_id = azurerm_network_security_group.dr_backend.id

}

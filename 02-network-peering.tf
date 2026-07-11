###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : 02-network-peering.tf
#
# Chapter     : Hub & Spoke Connectivity
#
# Description :
#
# Création des connexions VNet Peering entre :
#
#   - Hub      <-> Workload Spoke
#   - Hub      <-> Disaster Recovery Spoke
#
#
# Cette étape met en place la fondation de l'architecture
# Hub & Spoke Azure.
#
###############################################################


###############################################################
#
# HUB -> WORKLOAD PEERING
#
# Direction :
#
#   Hub Australia East
#          |
#          |
#   Workload Australia East
#
#
# Le Hub autorisera le transit des services centralisés.
#
# Dans les prochains chapitres, le Hub hébergera :
#
#   - Azure Firewall
#   - VPN Gateway
#   - Route Server
#
###############################################################

resource "azurerm_virtual_network_peering" "hub_to_workload" {


  name = "peer-hub-to-workload"


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  remote_virtual_network_id = azurerm_virtual_network.workload.id



  #
  # Autorise la communication réseau entre VNets.
  #
  allow_virtual_network_access = true



  #
  # Autorise le passage de trafic provenant
  # d'une appliance réseau.
  #
  # Nécessaire pour les architectures :
  #
  # VM -> Firewall -> Spoke
  #
  allow_forwarded_traffic = true



  #
  # Le Hub pourra exposer une Gateway aux spokes.
  # # Echec si VPN Gateway n'existe pas encore

  allow_gateway_transit = true


}



###############################################################
#
# WORKLOAD -> HUB PEERING
#
# Le spoke consomme les services du Hub.
#
###############################################################

resource "azurerm_virtual_network_peering" "workload_to_hub" {


  name = "peer-workload-to-hub"


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.workload.name


  remote_virtual_network_id = azurerm_virtual_network.hub.id



  allow_virtual_network_access = true



  allow_forwarded_traffic = true



  #
  # Utilisation future de la Gateway du Hub.
  #
  # Exemple :
  #
  # VM spoke
  #    |
  #    v
  # VPN Gateway Hub
  #
  # # Echec si VPN Gateway n'existe pas encore
  use_remote_gateways = true


}



###############################################################
#
# HUB -> DR PEERING
#
# Connexion inter-région :
#
# Australia East
#        |
# Azure backbone
#        |
# East Asia
#
###############################################################

resource "azurerm_virtual_network_peering" "hub_to_dr" {


  name = "peer-hub-to-dr"


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.hub.name


  remote_virtual_network_id = azurerm_virtual_network.dr.id



  allow_virtual_network_access = true



  allow_forwarded_traffic = true



  allow_gateway_transit = false


}



###############################################################
#
# DR -> HUB PEERING
#
###############################################################

resource "azurerm_virtual_network_peering" "dr_to_hub" {


  name = "peer-dr-to-hub"


  resource_group_name = azurerm_resource_group.network.name


  virtual_network_name = azurerm_virtual_network.dr.name


  remote_virtual_network_id = azurerm_virtual_network.hub.id



  allow_virtual_network_access = true



  allow_forwarded_traffic = true

  # # Echec si VPN Gateway n'existe pas encore

  use_remote_gateways = true


}

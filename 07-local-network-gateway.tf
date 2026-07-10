###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File : 07-local-network-gateway.tf
#
# Description
#
# Déclare le site distant (On-Premises).
#
# Cette ressource représente le routeur VPN distant
# (pfSense dans notre laboratoire).
#
# Aucun tunnel n'est créé ici.
#
# Le tunnel IPsec sera créé dans
# 08-vpn-connection.tf
#
###############################################################

###############################################################
#
# LOCAL NETWORK GATEWAY
#
###############################################################

resource "azurerm_local_network_gateway" "onprem" {

  name = "lng-home-lab"

  location = local.regions.primary

  resource_group_name = azurerm_resource_group.network.name

  #############################################################
  #
  # Public IP
  #
  #############################################################

  gateway_address = local.onprem.gateway_public_ip

  #############################################################
  #
  # Networks advertised by on-premises
  #
  #############################################################

  address_space = local.onprem.address_spaces

  #############################################################
  #
  # BGP
  #
  #############################################################

  bgp_settings {

    asn = local.onprem.bgp.asn

    bgp_peering_address = local.onprem.bgp.peer_ip

  }

  tags = local.common_tags

}

###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : 06-vpn-gateway.tf
#
# Chapter     : Azure VPN Gateway
#
# Description :
#
# Déploiement de la passerelle VPN du Hub Azure.
#
# Cette passerelle permettra ensuite de mettre en oeuvre :
#
#   - VPN Site-to-Site IPsec
#   - BGP dynamique
#   - Gateway Transit vers les spokes
#
#
# Configuration :
#
#   Region :
#       Australia East
#
#   SKU :
#       VpnGw1AZ
#
#   Mode :
#       Active-Passive
#
#   BGP :
#       Enabled
#
#   Azure ASN :
#       65515 (default)
#
#   APIPA BGP peer :
#       169.254.21.1
#
###############################################################


###############################################################
#
# AZURE VPN GATEWAY
#
###############################################################

resource "azurerm_virtual_network_gateway" "vpn" {

  name = "vpngw-aue-hub"


  location = local.regions.primary


  resource_group_name = azurerm_resource_group.network.name



  #############################################################
  #
  # Gateway configuration
  #
  #############################################################

  type = "Vpn"


  vpn_type = "RouteBased"



  #############################################################
  #
  # SKU
  #
  # VpnGw1AZ provides:
  #
  # - Availability Zone support
  # - BGP capability
  # - suitable bandwidth for lab scenarios
  #
  #############################################################

  sku = "VpnGw1AZ"



  #############################################################
  #
  # Active-Active disabled
  #
  # One public IP only.
  #
  #############################################################

  active_active = false



  #############################################################
  #
  # BGP configuration
  #
  #############################################################

  bgp_enabled = true


  bgp_settings {

    asn = 65515


    peer_weight = 0


    peering_addresses {

      ip_configuration_name = "vpn-gateway-ip-config"

      apipa_addresses = [
        "169.254.21.1"
      ]

    }

  }



  #############################################################
  #
  # Public IP + GatewaySubnet binding
  #
  #############################################################

  ip_configuration {

    name = "vpn-gateway-ip-config"

    public_ip_address_id = azurerm_public_ip.vpn_gateway.id

    private_ip_address_allocation = "Dynamic"

    subnet_id = azurerm_subnet.gateway.id

  }


  tags = local.common_tags

}

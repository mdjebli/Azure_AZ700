###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File : 08-vpn-connection.tf
#
# Description :
#
# Création de la connexion VPN Site-to-Site IPsec entre :
#
#   - Azure VPN Gateway
#   - Local Network Gateway (On-Premises)
#
#
# Paramètres :
#
#   IKE       : IKEv2
#   BGP       : Enabled
#
#   Phase 1 :
#       AES256
#       SHA256
#       DH Group 24
#
#   Phase 2 :
#       AES256
#       SHA256
#       PFS Group 24
#
###############################################################


###############################################################
#
# VPN CONNECTION
#
###############################################################

resource "azurerm_virtual_network_gateway_connection" "onprem" {


  name = local.vpn.connection_name


  location = local.regions.primary


  resource_group_name = azurerm_resource_group.network.name



  #############################################################
  #
  # Connection type
  #
  #############################################################

  type = "IPsec"



  #############################################################
  #
  # Azure VPN Gateway
  #
  #############################################################

  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id



  #############################################################
  #
  # Remote VPN Gateway
  #
  #############################################################

  local_network_gateway_id = azurerm_local_network_gateway.onprem.id



  #############################################################
  #
  # Pre-shared key
  #
  #############################################################

  shared_key = local.vpn.shared_key



  #############################################################
  #
  # Enable dynamic routing
  #
  # BGP exchanges routes dynamically.
  #
  #############################################################

  enable_bgp = true



  #############################################################
  #
  # Custom IPsec policy
  #
  #############################################################

  ipsec_policy {

    dh_group = "DHGroup24"


    ike_encryption = "AES256"

    ike_integrity = "SHA256"



    ipsec_encryption = "AES256"

    ipsec_integrity = "SHA256"



    pfs_group = "PFS24"


  }



  #############################################################
  #
  # Tags
  #
  #############################################################

  tags = local.common_tags


}

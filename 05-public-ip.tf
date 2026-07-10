###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : 05-public-ip.tf
#
# Chapter     : Public IP Infrastructure
#
# Description :
#
# Création des Public IP Azure nécessaires aux services
# réseau qui seront déployés dans les chapitres suivants.
#
# Services concernés :
#
#   - Azure Firewall
#   - VPN Gateway
#   - Azure Bastion
#   - NAT Gateway workload
#   - NAT Gateway DR
#
#
# Aucun service n'est associé dans ce chapitre.
#
# Les associations seront réalisées dans les fichiers
# correspondant aux services.
#
###############################################################


###############################################################
#
# AZURE FIREWALL PUBLIC IP
#
###############################################################

resource "azurerm_public_ip" "firewall" {

  name                = "pip-aue-firewall"
  location            = local.regions.primary
  resource_group_name = azurerm_resource_group.network.name

  allocation_method = "Static"

  sku = "Standard"

  zones = [
    "1",
    "2",
    "3"
  ]


  tags = local.common_tags

}



###############################################################
#
# VPN GATEWAY PUBLIC IP
#
###############################################################

resource "azurerm_public_ip" "vpn_gateway" {

  name                = "pip-aue-vpn-gateway"
  location            = local.regions.primary
  resource_group_name = azurerm_resource_group.network.name

  allocation_method = "Static"

  sku = "Standard"

  zones = [
    "1",
    "2",
    "3"
  ]


  tags = local.common_tags

}



###############################################################
#
# AZURE BASTION PUBLIC IP
#
###############################################################

resource "azurerm_public_ip" "bastion" {

  name                = "pip-aue-bastion"
  location            = local.regions.primary
  resource_group_name = azurerm_resource_group.network.name

  allocation_method = "Static"

  sku = "Standard"

  zones = [
    "1",
    "2",
    "3"
  ]


  tags = local.common_tags

}



###############################################################
#
# NAT GATEWAY PUBLIC IP
#
# WORKLOAD SPOKE
#
#Sur un compte Azure gratuit, pas plus de 3 IP publiques
#par région. Décommentez si autre compte et si utile
###############################################################

#resource "azurerm_public_ip" "nat_gateway" {

#  name                = "pip-aue-natgw"
#  location            = local.regions.primary
#  resource_group_name = azurerm_resource_group.network.name

#  allocation_method = "Static"

#  sku = "Standard"


#  tags = local.common_tags

#}



###############################################################
#
# NAT GATEWAY PUBLIC IP
#
# DR SPOKE
#
###############################################################

resource "azurerm_public_ip" "nat_gateway_dr" {

  name                = "pip-eas-natgw-dr"
  location            = local.regions.disaster_recovery
  resource_group_name = azurerm_resource_group.network.name

  allocation_method = "Static"

  sku = "Standard"


  tags = local.common_tags

}

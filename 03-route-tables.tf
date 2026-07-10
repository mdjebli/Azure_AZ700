###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : 03-route-tables.tf
#
# Chapter     : Route Tables
#
# Description :
#
# Création des Route Tables du laboratoire.
#
# Aucune route n'est créée à ce stade.
#
# Les routes seront ajoutées dans le chapitre Azure Firewall,
# lorsque le prochain saut (Next Hop) sera connu.
#
###############################################################

###############################################################
#
# WORKLOAD FRONTEND ROUTE TABLE
#
###############################################################

resource "azurerm_route_table" "workload_frontend" {

  name                = local.route_tables.workload_frontend.name
  location            = local.regions.primary
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags

}


###############################################################
#
# WORKLOAD BACKEND ROUTE TABLE
#
###############################################################

resource "azurerm_route_table" "workload_backend" {

  name                = local.route_tables.workload_backend.name
  location            = local.regions.primary
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags

}


###############################################################
#
# DR FRONTEND ROUTE TABLE
#
###############################################################

resource "azurerm_route_table" "dr_frontend" {

  name                = local.route_tables.dr_frontend.name
  location            = local.regions.disaster_recovery
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags

}


###############################################################
#
# DR BACKEND ROUTE TABLE
#
###############################################################

resource "azurerm_route_table" "dr_backend" {

  name                = local.route_tables.dr_backend.name
  location            = local.regions.disaster_recovery
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags

}


###############################################################
#
# ASSOCIATION
# WORKLOAD FRONTEND
#
###############################################################

resource "azurerm_subnet_route_table_association" "workload_frontend" {

  subnet_id      = azurerm_subnet.frontend.id
  route_table_id = azurerm_route_table.workload_frontend.id

}


###############################################################
#
# ASSOCIATION
# WORKLOAD BACKEND
#
###############################################################

resource "azurerm_subnet_route_table_association" "workload_backend" {

  subnet_id      = azurerm_subnet.backend.id
  route_table_id = azurerm_route_table.workload_backend.id

}


###############################################################
#
# ASSOCIATION
# DR FRONTEND
#
###############################################################

resource "azurerm_subnet_route_table_association" "dr_frontend" {

  subnet_id      = azurerm_subnet.dr_frontend.id
  route_table_id = azurerm_route_table.dr_frontend.id

}


###############################################################
#
# ASSOCIATION
# DR BACKEND
#
###############################################################

resource "azurerm_subnet_route_table_association" "dr_backend" {

  subnet_id      = azurerm_subnet.dr_backend.id
  route_table_id = azurerm_route_table.dr_backend.id

}

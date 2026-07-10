###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : outputs.tf
#
# Description :
#
# Exposition des identifiants nécessaires aux prochains
# chapitres Terraform.
#
###############################################################


###############################################################
# Resource Group
###############################################################

output "network_resource_group_name" {

  description = "Network resource group name"

  value = azurerm_resource_group.network.name

}


###############################################################
# Virtual Networks
###############################################################

output "hub_vnet_id" {

  description = "Hub VNet resource ID"

  value = azurerm_virtual_network.hub.id

}


output "workload_vnet_id" {

  description = "Workload spoke VNet resource ID"

  value = azurerm_virtual_network.workload.id

}


output "dr_vnet_id" {

  description = "Disaster Recovery spoke VNet resource ID"

  value = azurerm_virtual_network.dr.id

}


###############################################################
# Hub Subnets
###############################################################

output "gateway_subnet_id" {

  description = "VPN Gateway subnet ID"

  value = azurerm_subnet.gateway.id

}


output "firewall_subnet_id" {

  description = "Azure Firewall subnet ID"

  value = azurerm_subnet.firewall.id

}


output "firewall_management_subnet_id" {

  description = "Azure Firewall Management subnet ID"

  value = azurerm_subnet.firewall_management.id

}


output "bastion_subnet_id" {

  description = "Azure Bastion subnet ID"

  value = azurerm_subnet.bastion.id

}


output "route_server_subnet_id" {

  description = "Azure Route Server subnet ID"

  value = azurerm_subnet.route_server.id

}


output "dns_inbound_subnet_id" {

  description = "Private DNS Resolver inbound subnet ID"

  value = azurerm_subnet.dns_inbound.id

}


output "dns_outbound_subnet_id" {

  description = "Private DNS Resolver outbound subnet ID"

  value = azurerm_subnet.dns_outbound.id

}


output "private_endpoints_subnet_id" {

  description = "Private Endpoint subnet ID"

  value = azurerm_subnet.private_endpoints.id

}


###############################################################
# Workload Subnets
###############################################################

output "frontend_subnet_id" {

  description = "Workload frontend subnet ID"

  value = azurerm_subnet.frontend.id

}


output "backend_subnet_id" {

  description = "Workload backend subnet ID"

  value = azurerm_subnet.backend.id

}


###############################################################
# DR Subnets
###############################################################

output "dr_frontend_subnet_id" {

  description = "DR frontend subnet ID"

  value = azurerm_subnet.dr_frontend.id

}


output "dr_backend_subnet_id" {

  description = "DR backend subnet ID"

  value = azurerm_subnet.dr_backend.id

}

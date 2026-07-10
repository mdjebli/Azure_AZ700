###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : locals.tf
#
# Description :
# Centralisation de la configuration globale du laboratoire.
#
# Ce fichier contient :
#
#   - régions Azure
#   - noms des ressources
#   - conventions de nommage
#   - plan d'adressage réseau
#   - tags communs
#
###############################################################


locals {


  #############################################################
  # Regions
  #############################################################

  regions = {

    primary = "Australia East"

    disaster_recovery = "East Asia"

  }


  #############################################################
  # Global naming
  #
  # Les noms sont centralisés afin d'éviter toute divergence
  # entre les différents chapitres Terraform.
  #
  #############################################################

  naming = {

    project = var.project_name

    environment = var.environment

    location_primary_short = "aue"

    location_dr_short = "eas"

  }


  #############################################################
  # Resource Groups
  #############################################################

  resource_groups = {

    network = "rg-${local.naming.project}-${local.naming.environment}-network"

  }


  #############################################################
  # Virtual Networks
  #############################################################

  virtual_networks = {

    hub = {

      name = "vnet-${local.naming.location_primary_short}-hub"

      address_space = [
        "10.0.0.0/16"
      ]

    }


    workload = {

      name = "vnet-${local.naming.location_primary_short}-workload"

      address_space = [
        "10.10.0.0/16"
      ]

    }


    disaster_recovery = {

      name = "vnet-${local.naming.location_dr_short}-workload-dr"

      address_space = [
        "10.20.0.0/16"
      ]

    }

  }


  #############################################################
  # Hub Subnets
  #
  # Les noms GatewaySubnet, AzureFirewallSubnet et
  # AzureBastionSubnet sont imposés par Azure.
  #
  #############################################################

  hub_subnets = {


    gateway = {

      name = "GatewaySubnet"

      prefix = "10.0.0.0/27"

    }


    firewall = {

      name = "AzureFirewallSubnet"

      prefix = "10.0.0.64/26"

    }


    firewall_management = {

      name = "AzureFirewallManagementSubnet"

      prefix = "10.0.0.128/26"

    }


    bastion = {

      name = "AzureBastionSubnet"

      prefix = "10.0.1.0/26"

    }


    route_server = {

      name = "RouteServerSubnet"

      prefix = "10.0.1.64/27"

    }


    dns_inbound = {

      name = "snet-dns-inbound"

      prefix = "10.0.1.96/28"

    }


    dns_outbound = {

      name = "snet-dns-outbound"

      prefix = "10.0.1.112/28"

    }


    private_endpoints = {

      name = "snet-private-endpoints"

      prefix = "10.0.2.0/24"

    }


  }


  #############################################################
  # Workload Subnets
  #############################################################

  workload_subnets = {


    frontend = {

      name = "snet-frontend"

      prefix = "10.10.1.0/24"

    }


    backend = {

      name = "snet-backend"

      prefix = "10.10.2.0/24"

    }


  }


  #############################################################
  # Disaster Recovery Subnets
  #############################################################

  dr_subnets = {


    frontend = {

      name = "snet-frontend"

      prefix = "10.20.1.0/24"

    }


    backend = {

      name = "snet-backend"

      prefix = "10.20.2.0/24"

    }


  }

  #############################################################
  # Route tables
  #############################################################

  route_tables = {

    workload_frontend = {
      name = "rt-aue-workload-frontend"
    }

    workload_backend = {
      name = "rt-aue-workload-backend"
    }

    dr_frontend = {
      name = "rt-eas-dr-frontend"
    }

    dr_backend = {
      name = "rt-eas-dr-backend"
    }

  }




  #############################################################
  # Common Tags
  #############################################################

  common_tags = {


    Project = var.project_name


    Environment = var.environment


    ManagedBy = "Terraform"


    Architecture = "AZ700-Real-World-Lab"


  }

  ###############################################################
  #
  # ON-PREMISES CONFIGURATION
  #
  ###############################################################



  onprem = {

    site_name = "home-lab"

    gateway_public_ip = "91.160.122.65"

    address_spaces = [
      "172.16.1.0/24"
    ]

    bgp = {

      asn = 65001

      peer_ip = "169.254.21.2"

    }

  }

  ###############################################################
  #
  # VPN CONFIGURATION
  #
  ###############################################################

  vpn = {

    connection_name = "conn-aue-hub-to-onprem"

    connection_type = "IPsec"

    shared_key = "azerty"

  }
}




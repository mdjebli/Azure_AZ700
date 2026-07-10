###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : versions.tf
# Description : Terraform and Provider version constraints
#
###############################################################

terraform {

  required_version = ">= 1.12.0"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.37"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }

  }

}

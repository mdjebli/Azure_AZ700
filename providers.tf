###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : providers.tf
# Description : AzureRM Provider Configuration
#
###############################################################

provider "azurerm" {

  features {}

  subscription_id = var.subscription_id

}

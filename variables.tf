###############################################################
#
# AZ-700 REAL WORLD LAB
#
# File        : variables.tf
#
###############################################################

variable "subscription_id" {

  description = "Azure Subscription ID"

  type = string

}

variable "project_name" {

  description = "Project name"

  type = string

  default = "az700"

}

variable "environment" {

  description = "Deployment environment"

  type = string

  default = "lab"

}

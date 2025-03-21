terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.21.1"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id = var.subscription_id
}
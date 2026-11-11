terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.13.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  # v5 defaults to "none"; keep v4 behaviour so required RPs get registered
  resource_provider_registrations = "legacy"
  features {}
  storage_use_azuread = true
  subscription_id = var.subscription_id
}
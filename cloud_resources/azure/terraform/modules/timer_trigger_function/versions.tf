terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.21"
    }
  }
  required_version = ">= 1.11"
}
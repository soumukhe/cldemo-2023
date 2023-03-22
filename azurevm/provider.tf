terraform {
  required_version = ">0.13"
  required_providers {
    azurerm = "~>2.0"
  }
}

provider "azurerm" {
  subscription_id = var.azurestuff.subscription_id
  client_id       = var.azurestuff.client_id
  client_secret   = var.azurestuff.client_secret
  tenant_id       = var.azurestuff.tenant_id
  features {}
}

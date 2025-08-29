terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.42.0"
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "Donotdelete"
    storage_account_name = "shivajitustorage1"
    container_name       = "shivacontainer1"
    key                  = "shiva.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id ="2f58bc69-5c25-4e57-96df-4f99e2da2be7"
  }
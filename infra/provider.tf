terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
    
    backend "azurerm" {
        resource_group_name  = "azurerm_resource_group.rg.name"
        storage_account_name = "azurerm_storage_account.stg.name"
        container_name       = "azurerm_storage_container.ctn.name"
        key                  = "root.terraform.tfstate"
    }

}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

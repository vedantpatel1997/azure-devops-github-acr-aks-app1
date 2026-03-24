terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.65.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.0"
    }
  }

  backend "azurerm" {
    use_azuread_auth     = true
    resource_group_name  = "TerraformStorageAccount"
    storage_account_name = "strgterraformvp"
    container_name       = "tfstatefiles"
    key                  = "aks.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Adds a short unique suffix to names that must be globally unique in Azure.
resource "random_pet" "aks_suffix" {
  length = 2
}

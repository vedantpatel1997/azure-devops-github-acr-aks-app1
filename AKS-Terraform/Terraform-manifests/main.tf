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
  }

    backend "azurerm" {}

  # Commented terraform backend as we are using devops pipeline to manage state. If you want to use local state, uncomment the backend block and configure as needed.
  # backend "azurerm" {
  #   use_azuread_auth     = true
  #   resource_group_name  = "TerraformStorageAccount"
  #   storage_account_name = "strgterraformvp"
  #   container_name       = "tfstatefiles"
  #   # Backend blocks cannot use input variables. Keep the shared container

  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


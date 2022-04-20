# Configure Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.2.0"
    }
  }
  required_version = ">=1.1.0"
}

# Configure MS Azure Provider
provider "azurerm" {
  features {}
}

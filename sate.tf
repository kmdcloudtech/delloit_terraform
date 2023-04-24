# Terraform block  
terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "3.33.0"
    }
  }
}
# provider block 
provider "azurerm" {
    features {}
    subscription_id = "63ce4195-0436-4ed2-bc68-cf75c49d8418"
  
}

# Resource Block 
resource "azurerm_resource_group" "TestRG" {   # for terraform refrence 
    name = "TestRG"   # for Human reference for portal 
    location = "Central India"

    tags = {
      "Team" = "Test"   # go to portal and edit tags manually and again run terraform apply 
      "Owner" = "Deepak"
    }
    
  
}
/*
terraform apply 
terraform destroy 

*/ 

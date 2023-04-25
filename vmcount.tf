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

# Resource blocks 
# Resource Group Code 

resource "azurerm_resource_group" "my_demo_rg" {

  name     = "my_demo_rg-${count.index}"
  location = "Central India"
  count = 2 
}

# Virtual Net code 
resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet-${count.index}"
  count               = 2
  address_space       = ["10.0.0.0/16"]
  location            = element(azurerm_resource_group.my_demo_rg[*].location, count.index)
  resource_group_name = element(azurerm_resource_group.my_demo_rg[*].name, count.index)
}

# Subnet code 
resource "azurerm_subnet" "mysubent" {
  name                 = "mysubnet-${count.index}"
  count                =  2
  resource_group_name  = element(azurerm_resource_group.my_demo_rg[*].name, count.index)
  virtual_network_name = element(azurerm_virtual_network.myvnet[*].name, count.index)
  address_prefixes     = ["10.0.2.0/24"]
}
# public IP code 
resource "azurerm_public_ip" "mypublicip" {
  name = "mypublicip-${count.index}"
  count = 2
  resource_group_name = element(azurerm_resource_group.my_demo_rg[*].name, count.index)
  location = element(azurerm_resource_group.my_demo_rg[*].location, count.index)
  allocation_method = "Static"  
}

 # NIC code 
resource "azurerm_network_interface" "mynic" {
  name                = "mynic-${count.index}"
  count               =  2 
  location            = element(azurerm_resource_group.my_demo_rg[*].location, count.index)
  resource_group_name = element(azurerm_resource_group.my_demo_rg[*].name, count.index)

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(azurerm_subnet.mysubent[*].id, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = element(azurerm_public_ip.mypublicip[*].id, count.index)
  }
}


# Virtual Machine code 

resource "azurerm_linux_virtual_machine" "myvm" {
  name                = "myvm-${count.index}"
  count               = 2
  resource_group_name = element(azurerm_resource_group.my_demo_rg[*].name, count.index)
  location            = element(azurerm_resource_group.my_demo_rg[*].location, count.index)
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  disable_password_authentication = false 
  network_interface_ids = [element(azurerm_network_interface.mynic[*].id, count.index)]


  os_disk {
    name =  "osdisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

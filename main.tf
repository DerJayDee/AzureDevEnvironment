# Create RG
resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}rg-${local.location_short}"
  location = "West Europe"
}

# Create VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}vnet-${local.location_short}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Subnet
resource "azurerm_subnet" "vnet_subnet_default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "pip" {
  name                = "${local.prefix}vm01-pip-${local.location_short}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku                 = "Basic"
  allocation_method   = "Dynamic"
}

# Create Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${local.prefix}vm01-nic-${local.location_short}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.prefix}vm01-nic-${local.location_short}"
    subnet_id                     = azurerm_subnet.vnet_subnet_default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Create VM
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${local.prefix}vm01-${local.location_short}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name

  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B8ms"

  admin_username        = "vmadmin"
  admin_password        = var.vm-pwd

  timezone = "W. Europe Standard Time"

  os_disk {
    name                 = "${local.prefix}vm01-osdisk-${local.location_short}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-21h2-entn-g2"
    version   = "latest"
  }
}

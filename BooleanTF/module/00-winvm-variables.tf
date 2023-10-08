variable "create_vm" {
  description = "If set to true, it will create vm"
  type        = bool
}



resource "azurerm_resource_group" "rg" {
  name     = "ResourceGroup-VM-1"
  location = "brazil south"

}

resource "azurerm_virtual_network" "virtualNetwork" {
  name                = "vNet-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "snet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nictf" {
  name                = "terranic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.create_vm ? 1 : 0
  name                = "terra-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nictf.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
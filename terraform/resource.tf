resource "azurerm_resource_group" "localservicefinder" {

  name = "localservicefinder"

  location = "South India"
}


resource "azurerm_storage_account" "localservicefinder_storageaccount" {

  name                     = "localservicefinders"
  resource_group_name      = azurerm_resource_group.localservicefinder.name
  location                 = azurerm_resource_group.localservicefinder.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}


resource "azurerm_storage_container" "localservicefinder_storagecontainer" {

  name                  = "localservicefinderstoragecontainer"
  storage_account_name  = azurerm_storage_account.localservicefinder_storageaccount.name
  container_access_type = "private"

}

resource "azurerm_virtual_network" "localservicefinder_vnet" {
  name = "localservicefindervnet"

  resource_group_name = azurerm_resource_group.localservicefinder.name
  location            = azurerm_resource_group.localservicefinder.location
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "localservicefinder_frontend_subnet" {
  name                 = "localservicefinderfrontendsubnet"
  resource_group_name  = azurerm_resource_group.localservicefinder.name
  virtual_network_name = azurerm_virtual_network.localservicefinder_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_subnet" "localservicefinder_backend_subnet" {
  name                 = "localservicefinderbackendsubnet"
  resource_group_name  = azurerm_resource_group.localservicefinder.name
  virtual_network_name = azurerm_virtual_network.localservicefinder_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

}


resource "azurerm_network_security_group" "localservicefinder_nsg" {

  name = "localservicefindernsg"

  resource_group_name = azurerm_resource_group.localservicefinder.name
  location            = azurerm_resource_group.localservicefinder.location
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Nodejs"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }




}

resource "azurerm_subnet_network_security_group_association" "localservicefinder_frontend_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.localservicefinder_frontend_subnet.id
  network_security_group_id = azurerm_network_security_group.localservicefinder_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "localservicefinder_backend_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.localservicefinder_backend_subnet.id
  network_security_group_id = azurerm_network_security_group.localservicefinder_nsg.id
}

resource "azurerm_public_ip" "localservicefinder_public_ip" {
  name                = "localservicefinderpublicip"
  resource_group_name = azurerm_resource_group.localservicefinder.name
  location            = azurerm_resource_group.localservicefinder.location
  allocation_method   = "Static"
}


resource "azurerm_public_ip" "localservicefinder_public_ip_backend" {
  name                = "localservicefinderpublicipbackend"
  resource_group_name = azurerm_resource_group.localservicefinder.name
  location            = azurerm_resource_group.localservicefinder.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "localservicefinder_frontend_nic" {
  name                = "localservicefinderfrontendnic"
  resource_group_name = azurerm_resource_group.localservicefinder.name
  location            = azurerm_resource_group.localservicefinder.location
  ip_configuration {

    name                          = "localservicefinder_frontend_ip_configuration"
    subnet_id                     = azurerm_subnet.localservicefinder_frontend_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.localservicefinder_public_ip.id
  }
}

resource "azurerm_network_interface" "localservicefinder_backend_nic" {
  name                = "localservicefinderbackendnic"
  resource_group_name = azurerm_resource_group.localservicefinder.name
  location            = azurerm_resource_group.localservicefinder.location
  ip_configuration {

    name                          = "localservicefinder_backend_ip_configuration"
    subnet_id                     = azurerm_subnet.localservicefinder_backend_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.localservicefinder_public_ip_backend.id
  }
}



resource "azurerm_linux_virtual_machine" "localservicefinderfrontendvm" {

  name                            = "localservicefinderfrontendvm"
  resource_group_name             = azurerm_resource_group.localservicefinder.name
  location                        = azurerm_resource_group.localservicefinder.location
  size                            = "Standard_D4s_v3"
  admin_username                  = "nirmaladmin"
  admin_password                  = "according to you"
  network_interface_ids           = [azurerm_network_interface.localservicefinder_frontend_nic.id]
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

connection {
  type        = "ssh"
  host        = azurerm_linux_virtual_machine.localservicefinderfrontendvm.public_ip_address
  user        = "nirmaladmin"
  password    = "Nirmal@12345"
}


provisioner "remote-exec" {

       inline = [
        
             "sudo apt update && sudo apt upgrade -y",

             "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -",


             "sudo apt install -y curl wget git nginx mysql-server nodejs"
      
      ]


}


}


output "azurerm_linux_virtual_machine_public_ip_address" {
  value = azurerm_linux_virtual_machine.localservicefinderfrontendvm.public_ip_address
}





  

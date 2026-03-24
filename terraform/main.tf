terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-final-report"
  location = "francecentral"
}

# 2. Réseau virtuel
resource "azurerm_virtual_network" "vnet" {
  name                = "k8s-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "k8s-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 3. Sécurité (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "k8s-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "K8sAPI"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AppPort"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 4. IPs Publiques
resource "azurerm_public_ip" "ip" {
  for_each            = toset(["master", "worker"])
  name                = "${each.key}-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5. Interfaces réseaux (NIC)
resource "azurerm_network_interface" "nic" {
  for_each            = toset(["master", "worker"])
  name                = "${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "link" {
  for_each                  = toset(["master", "worker"])
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 6. Machines Virtuelles
resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = toset(["master", "worker"])
  name                = "k8s-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("id_rsa_azure.pub") # Utilise le fichier .pub que tu viens de générer
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Outputs
output "IP_Master" {
  value = azurerm_linux_virtual_machine.vm["master"].public_ip_address
}

output "IP_Worker" {
  value = azurerm_linux_virtual_machine.vm["worker"].public_ip_address
}
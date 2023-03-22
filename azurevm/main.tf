# Locate the existing custom/golden image
data "azurerm_image" "search" {
  name                = var.image_name
  resource_group_name = var.image_rg
}

/*
output "image_id" {
  value = data.azurerm_image.search.id
}
*/
################################
# Locate the resource_group
data "azurerm_resource_group" "example" {
  #name = "CAPIC_cldemo_cldemo_eastus"
  name = join("", ["CAPIC_", var.tenant, "_", var.vrf, "_", var.region])
}
/*
output "resource_id" {
  value = data.azurerm_resource_group.example.id
}
*/
################################
#Locate the Virtual Network
data "azurerm_virtual_network" "example" {
  name                = var.vrf
  resource_group_name = data.azurerm_resource_group.example.name
}

/*
output "virtual_network_id" {
  value = data.azurerm_virtual_network.example.id
}

*/
################################
# Locate Azure VM Subnet
data "azurerm_subnet" "example" {
  name                 = var.vmsubnet
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_resource_group.example.name
}

/*
output "subnet_id" {
  value = data.azurerm_subnet.example.id
}
*/
################################
# Locate the default NSG

data "azurerm_network_security_group" "example" {
  name = var.vmsubnet
  #name = "CAPIC_INTERNAL_EP_SG_DEFAULT_cloudapp-dummy"
  resource_group_name = data.azurerm_resource_group.example.name
}
/*
output "NSG_ID" {
  value = data.azurerm_network_security_group.example.id
}
*/
################################


# Create public IPs
resource "azurerm_public_ip" "example" {
  name                = join("", [var.pubip_name, "${random_id.randomId.hex}"])
  location            = var.region
  resource_group_name = data.azurerm_resource_group.example.name
  allocation_method   = "Static" #"Dynamic"

  tags = {
    environment = var.pubip_name
  }
}


# Create network interface
resource "azurerm_network_interface" "example" {
  name                = join("", [var.nic_name, "${random_id.randomId.hex}"])
  location            = var.region
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }

  tags = {
    environment = var.nic_name
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = data.azurerm_network_security_group.example.id
}

######


# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = data.azurerm_resource_group.example.name

  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "smstorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "env1"
  }
}

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

###############################################
# Create virtual machine from image

resource "azurerm_linux_virtual_machine" "example" {
  name                  = var.vm_name
  location              = var.region
  resource_group_name   = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "clive-demo-disk0${random_id.randomId.hex}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  /*
# This is for normal Ubuntu Image
  source_image_reference {
    publisher = "Canonical"    #"Canonical"
    offer     = "UbuntuServer" #"UbuntuServer"
    sku       = "18.04-LTS"    # "18.04-LTS"
    version   = "latest"
  }
*/

  # Instead use the image that was created in images resource group  
  source_image_id = data.azurerm_image.search.id

  computer_name                   = var.vm_name
  admin_username                  = var.username #"azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.username
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.smstorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = "mytag1"
  }
}




###############################################
# write Private Key to local machine
resource "local_file" "private_key" {
  content  = tls_private_key.example_ssh.private_key_pem
  filename = "sshPrivateKey.priv" #"sshPrivateKey.priv"
}



output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.example.private_ip_address
}

/*
  value = tomap({
    for name, vm in azurerm_network_interface.example : name => vm.private_ip_address
  })
}
*/


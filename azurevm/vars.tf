# this is the file that defines the variables.  The values should be specified in terraform.tfvars


variable "region" {
  default = "eastus"
}

variable "tenant" {
  default = "cldemo"
}

variable "vrf" {
  default = "cldemo"
}

variable "vmsubnet" {
  default = "backend-subnet"
}

variable "pubip_name" {
  default = "publicIP1"
}

variable "nic_name" {
  default = "nic1"
}

variable "vm_name" {
  default = "cldemo-az-vm1"
}

# make sure to create image in the same region / account
variable "image_name" {
  default = "cldemo-azure1-image.v1"
}

variable "image_rg" {
  default = "images"
}

variable "username" {
  default = "azureuser"

}

variable "privateIP" {
  default = "somevalue"
}


# the below variable values should be put in override.tf
## Please do not put the Infra account related items for these values
variable "azurestuff" {
  type = map(any)
  default = {
    subscription_id = "getFromOverride.tf"
    client_id       = "getFromOverride.tf"
    client_secret   = "getFromOverride.tf"
    tenant_id       = "getFromOverride.tf"
  }

}


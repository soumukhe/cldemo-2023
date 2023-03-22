#  Define variables (can also put this block in a file named terraform.tfvars)
#  Default values can be defined here, which can be overwritten by values defined in terraform.tfvars
#  You can also create a overwrite.tf file where you can keep confidential values

variable "creds" {
  type = map(any)
  default = {
    username = "someuser"
    password = "something"
    url      = "someurl"
    #domain   = "remoteuserRadius" # comment out if using local ND user instead of remote user
  }
}


variable "awsstuff" {
  type = object({
    aws_account_id    = string
    aws_access_key_id = string
    aws_secret_key    = string
  })
  default = {
    aws_account_id    = "000000000000"
    aws_access_key_id = "00000000000000000000"
    aws_secret_key    = "0000000000000000000000000000000000000000"
  }
}


variable "azurestuff" {
  type = object({
    azure_subscription_id = string
  })
  default = {
    azure_subscription_id = "subscription"
  }
}

# Site names as seen on Nexus Dashboard

variable "aws_site_name" {
  type    = string
  default = "aws"
}

variable "azure_site_name" {
  type    = string
  default = "azure"
}

variable "onprem_site_name" {
  type    = string
  default = "onprem"
}


# Tenant

variable "tenant" {
  type = map(any)
  default = {
    tenant_name  = "somename"
    display_name = "somename"
    description  = "somename"
  }
}

# Template & Schema

variable "template1" {
  type = map(any)
  default = {
    name         = "something"
    display_name = "something"
  }
}

variable "schema_name" {
  type    = string
  default = "somename"
}

variable "vrf_name" {
  type    = string
  default = "something"
}

variable "aws_region_name" {
  type    = string
  default = "some_value"
}

variable "aws_zone1" {
  type    = string
  default = "some_value"
}

variable "aws_zone2" {
  type    = string
  default = "some_value"
}

variable "aws_zone3" {
  type    = string
  default = "some_value"
}

variable "aws_cidr_ip" {
  type    = string
  default = "some_value"
}


variable "aws_subnet1" {
  type    = string
  default = "some_value"
}


variable "aws_subnet2" {
  type    = string
  default = "some_value"
}

variable "aws_subnet3" {
  type    = string
  default = "some_value"
}



variable "tgw_name" {
  type    = string
  default = "your_tgw_name"
}




# User VNet in Azure

variable "azure_region_name" {
  type    = string
  default = "somevalue"
}

variable "azure_cidr_ip" {
  type    = string
  default = "some value"
}

variable "azure_user_subnets" {
  type = map(object({
    name = string
    ip   = string
  }))
  default = {
    web-subnet = {
      name = "backend-subnet"
      ip   = "10.70.1.0/24"
    }
  }
}


# BD related

variable "bd_name" {
  type    = string
  default = "somevalue"
}


variable "bd_subnet" {
  type    = string
  default = "somevalue"
}


variable "anp_name" {
  type    = string
  default = "some value"
}

variable "epg_name" {
  type    = string
  default = "some value"
}



variable "filter_name" {
  type    = string
  default = "some value"
}

variable "filter_entry_name" {
  type    = string
  default = "some value"
}

variable "contract_name" {
  type    = string
  default = "some value"
}


variable "template2" {
  type = map(any)
  default = {
    name         = "something"
    display_name = "something"
  }
}

variable "t2anp_name" {
  type    = string
  default = "some value"
}

variable "t2epg_name" {
  type    = string
  default = "some value"
}


variable "t2epg_sel1" {
  type    = string
  default = "some value"
}



variable "t2epg_sel2" {
  type    = string
  default = "some value"
}


variable "t2contract_name" {
  type    = string
  default = "some value"
}

variable "t2ext_epg" {
  type    = string
  default = "some value"
}


variable "t2ext_epg_selector" {
  type    = string
  default = "some value"
}


variable "t2ext_epg_selector_ip" {
  type    = string
  default = "some value"
}




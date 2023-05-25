# terraform.tfvars.  Define values of variables here.  Please do not put confidential information here. They go in override.tf


aws_site_name    = "AWS"
azure_site_name  = "AZURE"
onprem_site_name = "ACI"

# Tenant

tenant = {
  tenant_name  = "cldemo2023"
  display_name = "cldemo2023"
  description  = "cldemo2023"
}

# Templates/Schema

template1 = {
  name         = "shared"
  display_name = "shared"
}



schema_name = "cldemo2023"

aws_region_name = "us-east-1"
aws_zone1       = "us-east-1a"
aws_zone2       = "us-east-1a"
aws_zone3       = "us-east-1b"

aws_cidr_ip = "10.60.0.0/16"
aws_subnet1 = "10.60.1.0/24"
aws_subnet2 = "10.60.0.240/28"
aws_subnet3 = "10.60.2.240/28"


tgw_name = "tgw"

azure_region_name = "australiaeast"
azure_cidr_ip     = "10.70.0.0/16"
azure_user_subnets = {
  web-subnet = {
    name = "backend-subnet"
    ip   = "10.70.1.0/24"
  }
}

vrf_name  = "vrf-cldemo2023"
bd_name   = "bd-cldemo2023"
bd_subnet = "10.40.1.1/24"

anp_name = "ap-cldemo2023"
epg_name = "epg-cldemo2023"

filter_name       = "AnyFilter-cldemo2023"
filter_entry_name = "any"

contract_name = "c-alb_targetGroup"


# note below template2 is named "taws-only" so that the list contains this as element1.  element0 will be template1 with value of "cldemo2023"
template2 = {
  name         = "taws-only"
  display_name = "taws-only"
}



t2anp_name = "ap-alb"
t2epg_name = "epg-alb"

t2epg_sel1 = "sel-alb-subnet1"


t2epg_sel2 = "sel-alb-subnet2"



t2contract_name       = "c-aws-igw"
t2ext_epg             = "extEpg-igw"
t2ext_epg_selector    = "sel-extEPG"
t2ext_epg_selector_ip = "0.0.0.0/0"




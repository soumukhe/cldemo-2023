
# below block you might want to move to a file called versions.tf
terraform {
  required_version = ">1.0"
  required_providers {
    aws = {
      version = "~>3.6"
    }
  }
}


# you might want to move the block below to a file called aws_provider.tf
provider "aws" {
  region     = var.region
  access_key = var.awsstuff.aws_access_key_id
  secret_key = var.awsstuff.aws_secret_key
}

#  Get VPC ID of ACI built VPC on AWS:

data "aws_vpcs" "vpc_id" {
  tags = {
    AciPolicyDnTag = var.AciPolicyDnTag # adding filter for "uni/tn-cldemo/ctxprofile-cldemo-us-east-1"
  }
}


# Set a variable for vpcid value obtained
locals {
  vpcid = element(tolist(data.aws_vpcs.vpc_id.ids), 0)
}


#  Get the full map for subnet IDs
data "aws_subnet_ids" "example" {
  vpc_id = local.vpcid
}

# Choose the subnet ID where ec2 will get deployed

locals {
  my_subnets = var.ec2_subnet
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.example.ids
  id       = each.value
}

data "aws_subnet" "example1" {
  for_each = toset(local.my_subnets)

  cidr_block = each.key
}

locals {
  subnet_ids = tomap({
    for cidr, subnet in data.aws_subnet.example1 : cidr => subnet.id
  })
}

locals {
  # myec2subnet = local.subnet_ids["10.60.1.0/24"]
  myec2subnet = local.subnet_ids[var.ec2_subnet[0]]
}

# Verify you have the correct subnet ID
output "ec2-subnetid" {
  value = local.myec2subnet
}

# Upload public ssh key to AWS
##  Notice that this will upload my public key to AWS and use it for the EC2s.  This way, I an login with my private keys.
##  so, first do:   cp ~/.ssh/id_rsa.pub   ./.certs

resource "aws_key_pair" "loginkey" {
  key_name = try("login-key-3") #  using function try here.  If key is already present don't mess with it
  #public_key = file("${path.module}/.certs/id_rsa.pub")  # #  path.module is in relation to the current directory, in case you want to put your id_rsa.pub in ./.certs folder
  public_key = file("~/.ssh/id_rsa.pub")
}

## spin up the aws instances.  Note we are using count.index to spin up multiple ec2s as required
/*
data "aws_ami" "std_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
*/


resource "aws_instance" "aws-backend-ec2" {
  #ami                         = data.aws_ami.std_ami.id
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.myec2subnet
  associate_public_ip_address = true
  key_name                    = aws_key_pair.loginkey.key_name
  count                       = var.num_inst
  tags = {
    Name = "ec2-${count.index}-backend" # first instance will be ec2-0, then ec2-1 etc, etc
  }
}

## Show Private IPs
output "privateIP" {

  value = {
    for instance in aws_instance.aws-backend-ec2 :
    instance.id => instance.private_ip
  }
}





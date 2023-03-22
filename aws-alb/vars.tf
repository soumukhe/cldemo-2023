# this is the file that defines the variables.  The values should be specified in terraform.tfvars

variable "instance_type" { default = "t2.micro" }



variable "region" {
  default = "us-east-1"
}



variable "alb_subnets" {
  type    = list(any)
  default = ["10.60.0.240/28", "10.60.2.240/28"]
}

# get AciPolicyDnTag tag for VPC in AWS Console to verify.  This is derived from tenant and vrf name.
# uni/tn-cldemo/ctxprofile-cldemo-us-east-1
variable "AciPolicyDnTagVPC" {
  type    = string
  default = "*-cldemo*"
}

# get AciPolicyDnTag tag for SG in AWS Console to verify.  This is derived from app and epg name.
# uni/tn-cldemo/cloudapp-app-alb/cloudepg-epg-alb
variable "AciPolicyDnTagSG" {
  type    = string
  default = "*-epg-alb"
}

variable "alb_name" {
  default = "cldemo-alb1"
}

variable "targetGroup_name" {
  default = "cldemo-alb1-tg"
}


####  Below are IPs for alb target-group registeration

variable "aws_ec2_ip" {
  default = "10.60.1.88"
}

variable "azure_vm_ip" {
  default = "10.70.1.6"
}

variable "onprem_vm_ip" {
  default = "10.40.1.100"
}

# Note all AWS account related information should be for the AWS account where Tenant will be spun up.  
# Please do not put the Infra account related items for these values


variable "awsstuff" {
  type = map(any)
  default = {
    aws_account_id         = "getFrom-override.tf"
    is_aws_account_trusted = false
    aws_access_key_id      = "getFrom-override.tf"
    aws_secret_key         = "getFrom-override.tf"
  }
}

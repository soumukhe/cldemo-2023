# this is the file that defines the variables.  The values should be specified in terraform.tfvars

variable "instance_type" { default = "t2.micro" }



variable "region" {
  default = "us-east-1"
}





variable "num_inst" {
  type        = number
  description = "enter the number of instances you want"
}

variable "ec2_subnet" {
  type    = list(any)
  default = ["10.60.1.0/24"]
}

# get this from aws console
variable "ami_id" {
  type    = string
  default = "ami-09d89206f610495fa"
}

# get AciPolicyDnTag tag for VPC in AWS Console to verify.  This is derived from tenant and vrf name.
variable "AciPolicyDnTag" {
  type    = string
  default = "*-cldemo*"
}

# Note all AWS account related information should be for the AWS account where Tenant will be spun up.
# Please do not put the Infra account related items for these values
# below variables should be defined in override.tf

variable "awsstuff" {
  type = map(any)
  default = {
    aws_account_id         = "defineInOverride.tf"
    is_aws_account_trusted = false
    aws_access_key_id      = "defineInOverride.tf"
    aws_secret_key         = "defineInOverride.tf"
  }
}


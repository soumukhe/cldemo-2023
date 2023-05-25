# You can override the default values of variables in terraform.tfvars

num_inst = 1

region     = "us-east-1"
ec2_subnet = ["10.60.1.0/24"]
ami_id     = "ami-0f41820ffd8d5b489"

ec2-privateIP = ["10.60.1.100"]


# get AciPolicyDnTag tag for VPC in AWS Console to verify.  This is derived from tenant and vrf name.
AciPolicyDnTag = "*-cldemo*"
sgName = "*epg-cldemo*"

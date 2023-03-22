# terraform.tfvars
# You can override the default values of variables in this file: terraform.tfvars


region = "us-east-1"

alb_subnets = ["10.60.0.240/28", "10.60.2.240/28"]


# get AciPolicyDnTag tag for VPC in AWS Console to verify.  This is derived from tenant and vrf name.
# uni/tn-cldemo/ctxprofile-cldemo-us-east-1
AciPolicyDnTagVPC = "*-cldemo*"


# get AciPolicyDnTag tag for SG in AWS Console to verify.  This is derived from app and epg name.
# uni/tn-cldemo/cloudapp-app-alb/cloudepg-epg-alb
AciPolicyDnTagSG = "*-epg-alb"


alb_name         = "cldemo-alb1"
targetGroup_name = "cldemo-alb1-tg"

####  Below are IPs for alb target-group registeration
aws_ec2_ip   = "10.60.1.216"
azure_vm_ip  = "10.70.1.4"
onprem_vm_ip = "10.40.1.100"


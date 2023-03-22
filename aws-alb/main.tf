
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
    AciPolicyDnTag = var.AciPolicyDnTagVPC # adding filter for "uni/tn-cldemo/ctxprofile-vrf1-us-east-1"
  }
}
####################
data "aws_security_group" "alb-epg" {
  tags = {
    AciPolicyDnTag = var.AciPolicyDnTagSG # adding filter for "uni/tn-cldemo/cloudapp-app-alb/cloudepg-epg-alb"
  }
}

output "alb_sgid" {
  value = data.aws_security_group.alb-epg.id
}


################

# Set a variable for vpcid value obtained
locals {
  vpcid = element(tolist(data.aws_vpcs.vpc_id.ids), 0)
}


#  Get the full map for subnet IDs
data "aws_subnet_ids" "example" {
  vpc_id = local.vpcid
}

# Choose the subnet ID where alb will get deployed

locals {
  # my_subnets = ["10.60.0.240/28", "10.60.2.240/28"]
  my_subnets = var.alb_subnets
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
  albsubnet1 = local.subnet_ids[var.alb_subnets[0]]
}

locals {
  albsubnet2 = local.subnet_ids[var.alb_subnets[1]]
}

output "albsubnet1" {
  value = local.albsubnet1
}

output "albsubnet2" {
  value = local.albsubnet2
}

resource "aws_lb_target_group" "cl-demo-tg" {
  name        = var.targetGroup_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpcid
  target_type = "ip"
  slow_start  = 0

  load_balancing_algorithm_type = "round_robin"
  #load_balancing_algorithm_type = "least_outstanding_requests"


  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_lb" "cl-demo1" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.alb-epg.id]

  subnets = [
    local.albsubnet1,
    local.albsubnet2
  ]
}

resource "aws_lb_listener" "cl-demo1" {
  load_balancer_arn = aws_lb.cl-demo1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cl-demo-tg.arn
  }
}

############
#  attach targets ... comment out this block with /*  */  to destroy those resources, then run terraform apply again

resource "aws_lb_target_group_attachment" "aws_ec2" {
  target_group_arn = aws_lb_target_group.cl-demo-tg.arn
  target_id        = var.aws_ec2_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "azure_vm" {
  target_group_arn  = aws_lb_target_group.cl-demo-tg.arn
  target_id         = var.azure_vm_ip
  availability_zone = "all"
  port              = 80
}


resource "aws_lb_target_group_attachment" "onprem_vm" {
  target_group_arn  = aws_lb_target_group.cl-demo-tg.arn
  target_id         = var.onprem_vm_ip
  availability_zone = "all"
  port              = 80
}
#############
# outputs:

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = try(aws_lb.cl-demo1.dns_name, "")
}

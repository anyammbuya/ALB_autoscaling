# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  cidr = var.vpc_cidr_block
  name = var.vpc_name

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, 2)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, 2)

  # This ensures that the dafault NACL for the VPC has rules only for ipv4

  default_network_acl_ingress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    }
  ]

  default_network_acl_egress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    }
  ]

  enable_nat_gateway     = trueg
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  enable_ipv6 = false

  tags = var.vpc_tags

}
module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "lb-sg-project-zeus"
  description = "Load balancer security group"

  ingress_with_cidr_blocks = [

    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "http from every where"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "https from every where"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.vpc_tags
}

# Security group for the bastion host

resource "aws_security_group" "bastion-allow-ssh" {
  vpc_id      = module.vpc.vpc_id
  name        = "bastion-allow-ssh"
  description = "security group for bastion that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion-allow-ssh"
  }
}


# Web-app Security group

module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "app-sg-project-zeus"
  description = "Web server security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.lb_security_group.security_group_id
      description              = "Allows http from lb-sg-project-zeus"
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = aws_security_group.bastion-allow-ssh.id
      description              = "Allow ssh from bastion host sg"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  //the main reason allow incoming traffic from the public subnet is
  // so that if there is a bastion host in the public subnet, we can use it
  // to ssh into our private 

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = module.vpc.public_subnets_cidr_blocks[0]
      description = "Allows http from public subnets"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = module.vpc.public_subnets_cidr_blocks[1]
      description = "Allows http from public subnets"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = module.vpc.public_subnets_cidr_blocks[0]
      description = "Allows https from public subnets"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = module.vpc.public_subnets_cidr_blocks[1]
      description = "Allows https from public subnets"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 80 at any destination"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 443 at any destination"
    },
    {
      rule = "ssh-tcp"
      #cidr_blocks= module.vpc.public_subnets_cidr_blocks[0]
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 22 at any destination"


    }
  ]

  tags = var.vpc_tags
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "alb-${random_string.lb_id.result}-project-zeus"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.lb_security_group.security_group_id]

  target_groups = [
    {
      name_prefix      = "pzeus-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.vpc_tags


}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("${path.module}/mykey.pub")
}

module "zeus_launch_template" {
  source = "./modules/launch-template"

  instance_type      = var.instance_type
  security_group_ids = [module.app_security_group.security_group_id]
  key_name           = aws_key_pair.mykeypair.key_name
  tags               = var.vpc_tags
}
module "zeus_autoscaling_group" {
  source = "./modules/autoscaling-group"

  subnet_ids              = module.vpc.private_subnets[*]
  target_group_arns       = module.alb.target_group_arns
  launch_template_id      = module.zeus_launch_template.launch_template_id
  launch_template_version = module.zeus_launch_template.launch_template_version

}

module "bastion" {
  source = "./modules/bastion"

  instance_type             = var.instance_type
  subnet_id_public          = module.vpc.public_subnets[0]
  security_group_id_bastion = [aws_security_group.bastion-allow-ssh.id]
  key_name                  = aws_key_pair.mykeypair.key_name

}
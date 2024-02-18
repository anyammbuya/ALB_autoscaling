# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# Launch Template Resource

resource "aws_launch_template" "project-zeus-LT" {
  
  name          = "project-zeus-LT"
  description   = "Launch Template for project-zeus"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids
  
  //key_name = var.key_name 
  
  user_data = filebase64("${path.module}/webapp.sh")
  
  //ebs_optimized = true
  
  #default_version = 1

  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10     
      delete_on_termination = true
      volume_type = "gp3" # default is gp3
     }
  }
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags =var.tags
  }
}
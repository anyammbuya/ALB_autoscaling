# Autoscaling Group Resource
resource "aws_autoscaling_group" "project_zeus_ASG" {
  name_prefix = "project-zeus-"
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  vpc_zone_identifier  = var.subnet_ids
  
  target_group_arns = var.target_group_arns
  health_check_type = "EC2"
  health_check_grace_period = 300 
  
  # Launch Template
  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }
  
  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup = 300 
      min_healthy_percentage = 50
    }
    
  }  
   tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true
  }  
  tag {
    key                 = "project"
    value               = "zeus"
    propagate_at_launch = true
  }  
}
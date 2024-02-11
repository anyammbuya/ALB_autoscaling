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

# Create Autoscaling policy

resource "aws_autoscaling_policy" "avg_cpu_utilization" {

  name                   = "avg_cpu_utilization"

# Provide a scaling policy type either "SimpleScaling", "StepScaling" or
# "TargetTrackingScaling". AWS will default to to "SimpleScaling if 
# this value is not provided

  policy_type = "TargetTrackingScaling"  

  autoscaling_group_name = aws_autoscaling_group.project_zeus_ASG.name

  estimated_instance_warmup = 300  # 300 secs is default anyway

  # CPU Utilization is above 50

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }  

}
# Autoscaling Group Resource
resource "aws_autoscaling_group" "project_zeus_ASG" {

  name_prefix = "project-zeus-"
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  vpc_zone_identifier  = var.subnet_ids
  
  target_group_arns = var.target_group_arns
  health_check_type = "EC2"
  health_check_grace_period = 300 

 # use a lifecycle argument to ignore changes to the desired capacity and target groups
 # when terraform changes other aspects of your configuration

  lifecycle { 
    ignore_changes = [desired_capacity, target_group_arns]
  }

  
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

/*
# The policy configures your Auto Scaling group to destroy a member of the 
# ASG if the EC2 instances in your group use less than 10% CPU over 2 consecutive 
# evaluation periods of 2 minutes.


resource "aws_autoscaling_policy" "scale_down" {
  name                   = "project_zeus_ASG_down"
  autoscaling_group_name = aws_autoscaling_group.project_zeus_ASG.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

# cloudwatch alarm which triggers auto scaling

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitors CPU utilization for project_zeus_ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "project_zeus_ASG_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.project_zeus_ASG.name
  }
}
*/

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

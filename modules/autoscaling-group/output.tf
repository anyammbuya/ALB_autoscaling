
# Autoscaling Outputs
output "autoscaling_group_id" {
  description = "Autoscaling Group ID"
  value = aws_autoscaling_group.project_zeus_ASG.id 
}

output "autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.project_zeus_ASG.name 
}

output "autoscaling_group_arn" {
  description = "Autoscaling Group ARN"
  value = aws_autoscaling_group.project_zeus_ASG.arn 
}
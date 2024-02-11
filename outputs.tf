output "vpc_id" {
  description = "ID of project VPC"
  value       = module.vpc.vpc_id
}

output "lb_security_group_id" {
  description = "ID of lb-sg"
  value       = module.lb_security_group.security_group_id
}

output "app_security_group_id" {
  description = "ID of app_security_group"
  value       = module.app_security_group.security_group_id
}

output "lb_dns_name" {
  description = "ID of app_security_group"
  value       = module.alb.lb_dns_name
}
output "target_group_arns" {
  description = "ID of app_security_group"
  value       = module.alb.target_group_arns
}

output "launch_template_version" {
  description = "Latest version of the launch template"
  value       = module.zeus_launch_template.launch_template_version
}

output "autoscaling_group_id" {
  description = "Autoscaling Group ID"
  value       = module.zeus_autoscaling_group.autoscaling_group_id
}
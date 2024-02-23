output "cloudwatch_log_group_name" {
  description = "log group name for cloud watch"
  value       = aws_cloudwatch_log_group.ec2_session_logs.name
}
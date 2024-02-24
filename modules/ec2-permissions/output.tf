output "instance_profile_arn" {
  description = "arn of the ec2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "kms_key_id" {
  description = "arn of kms key"
  value = aws_kms_key.ec2_session.arn
}


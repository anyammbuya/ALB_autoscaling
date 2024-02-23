# Create cloudwatch logs group
resource "aws_cloudwatch_log_group" "ec2_session_logs" {
  name              = "ec2-session-logs"
  retention_in_days = "7"
  kms_key_id        = var.kms_key_id

  tags = {
    project  = "zeus"
    env      = "dev"
  }
}
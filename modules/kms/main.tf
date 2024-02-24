# Section for KMS key
resource "aws_kms_key" "ec2_session" {
  description             = "Key for EC2 session"
  deletion_window_in_days = var.deletion_days


  policy = file("modules/json-policy/ec2-session-policy-4-kms.json")

  tags = {
    project  = "zeus"
    env      = "dev"
  }
}

# Section for KMS key alias
resource "aws_kms_alias" "ec2_session" {
  name          = "alias/ec2-session"
  target_key_id = aws_kms_key.ec2_session.key_id
}
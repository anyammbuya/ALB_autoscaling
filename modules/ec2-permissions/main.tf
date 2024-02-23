#Create a role
#trust policy: which specifies who or what can assume the role

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2ssm"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#get the policy

resource "aws_iam_policy" "policy" {
  name        = "ec2-ssm-cloudw-s3"
  description = "A policy for ec2 to access ssm, cloudwatch and s3"
  policy      = file("modules/json-policy/ec2-policy-4-ssm-cloudwatch-s3.json")
}

#Attach role to policy

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.policy.arn
}

#Attach role to an instance profile

resource "aws_iam_instance_profile" "ec2_profile" {
  //name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_role.name
}

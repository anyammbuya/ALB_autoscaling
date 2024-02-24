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
  managed_policy_arns =[aws_iam_policy.ssm_policy.arn, aws_iam_policy.ec2_cw_policy.arn]
}

#get the policies

resource "aws_iam_policy" "ssm_policy" {
  name        = "ssmpolicy"
  description = "A policy for ec2 to access ssm"
  policy      = file("modules/json-policy/ec2-policy-4-ssm.json")
}

resource "aws_iam_policy" "ec2_cw_policy" {
  name        = "cloudw-policy"
  description = "A policy for ec2 to acces cloudwatch logs"
  policy      = file("modules/json-policy/ec2-session-policy-4-cw-logs.json")
}

/*

#I am taking out this block because it is not compartible with managed_policy_arns
#argument of aws_iam_role. I did this because i want to attach multiple poicies
#to the instance profile's role

#Attach role to policy

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.policy.arn
}

*/

#Attach role to an instance profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_role.name
}

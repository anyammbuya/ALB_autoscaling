#Create a role

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

#Attach role to policy

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#Attach role to an instance profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "zeus-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

/*
# You can use the code below to define a policy if you ain't using the arn of 
# a policy already defined by amazon 

resource "aws_iam_policy" "ec2_policy" {
  name        = "app-1-ec2-policy"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2024-01-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:List*"
        ],
        "Resource" : [
          "arn:aws:s3:::zeus-aws/download/*"
        ]
      }
    ]
  })
}

*/

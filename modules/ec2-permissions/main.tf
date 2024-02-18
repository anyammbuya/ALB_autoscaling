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
  name               = "ec2-trust-policy"
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
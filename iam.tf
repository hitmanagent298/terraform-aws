# IAM Policy
resource "aws_iam_policy" "full_access_policy" {
  name        = "omik-full-access-policy"
  description = "Policy to allow full access to RDS, EC2, Secrets Manager, Cloudfront, and S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["rds:*", "ec2:*", "secretsmanager:*", "cloudfront:*", "s3:*", "ecs:*"],
        Resource = ["*"]
      },
    ],
  })
}

# IAM Role
resource "aws_iam_role" "full_access_role" {
  name               = "omik-full-access-role"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
 }

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.full_access_role.name
  policy_arn = aws_iam_policy.full_access_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "omik-instance-profile" {
  name = "omik-full-access-instance-profile"
  role = aws_iam_role.full_access_role.name
}


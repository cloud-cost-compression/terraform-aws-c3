module "c3_admin_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.20.0"

  number_of_custom_role_policy_arns = 1
  create_instance_profile           = false
  create_role                       = true
  role_requires_mfa                 = false
  role_name                         = "c3-admin"
  trusted_role_arns                 = ["arn:aws:iam::${local.c3_admin_aws_account_id}:root"]
  role_sts_externalid               = var.c3_admin_external_id
  custom_role_policy_arns = [
    aws_iam_policy.c3_admin_policy.arn
  ]
}

resource "aws_iam_policy" "c3_admin_policy" {
  name = "c3-admin-access"
  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:List*",
          "ssm:StartSession",
          "ssm:StartAction",
          "ec2:Describe*",
        ]
        Resource = [
          "*"
        ]
        Condition : {
          "StringEqualsIgnoreCase" : { "aws:ResourceTag/Project" : [local.default_tags.Project] }
        },
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
        ]
        Resource = [
          "arn:aws:ssm:us-east-1::document/AWS-StartNonInteractiveCommand"
        ]
      }
    ]
    Version = "2012-10-17"
  })
}
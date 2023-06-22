# --- eks-k8s.tf ---

module "evl_job_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.20.0"
  create_role                   = true
  role_name_prefix              = "c3-evl-job-role"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_namespace_name}:${local.k8s_service_account_name}"]
  role_policy_arns = [
    aws_iam_policy.s3_metadata_access.arn
  ]
}

resource "aws_iam_policy" "s3_metadata_access" {
  name_prefix = "access_s3_metadata_policy"

  policy = jsonencode({
    Statement = [
      {
        Sid    = "AccessMetadataS3bucket"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Delete*"
        ]
        Resource = [
          aws_s3_bucket.c3_metadata.arn,
          "${aws_s3_bucket.c3_metadata.arn}/*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "s3_data_access" {
  count = var.s3_data_bucket_arn != "" ? 1 : 0

  name_prefix = "access_s3_data_policy"

  policy = jsonencode({
    Statement = [
      {
        Sid    = "AccessDataS3bucket"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Delete*"
        ]
        Resource = [
          var.s3_data_bucket_arn,
          "${var.s3_data_bucket_arn}/*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "controller_integration" {
  count = var.s3_data_bucket_arn != "" ? 1 : 0

  policy_arn = aws_iam_policy.s3_data_access[0].arn
  role       = module.evl_job_iam_role.iam_role_name
}

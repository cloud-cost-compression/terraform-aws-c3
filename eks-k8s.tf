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
          "s3:PutObject*",
          "s3:DeleteObject*"
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

resource "aws_iam_policy" "s3_data_read_access" {
  name_prefix = "access_s3_read_data_policy"

  policy = jsonencode({
    Statement = [
      {
        Sid    = "AccessDataS3bucket"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_data_read_bucket_name}",
          "arn:aws:s3:::${var.s3_data_read_bucket_name}/*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "s3_data_read_bucket_role_policy_attachment" {
  policy_arn = aws_iam_policy.s3_data_read_access.arn
  role       = module.evl_job_iam_role.iam_role_name
}

resource "aws_iam_policy" "s3_data_write_access" {
  name_prefix = "access_s3_write_data_policy"

  policy = jsonencode({
    Statement = [
      {
        Sid    = "AccessDataS3bucket"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject*",
          "s3:DeleteObject*"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_data_write_bucket_name}",
          "arn:aws:s3:::${var.s3_data_write_bucket_name}/*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "s3_data_write_bucket_role_policy_attachment" {
  policy_arn = aws_iam_policy.s3_data_write_access.arn
  role       = module.evl_job_iam_role.iam_role_name
}

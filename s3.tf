# --- s3.tf ---

resource "aws_s3_bucket" "c3_metadata" {
  bucket = "c3-metadata-${var.region}-${data.aws_caller_identity.current.account_id}"
  tags   = local.default_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "c3_metadata" {
  bucket = aws_s3_bucket.c3_metadata.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "c3_metadata" {
  bucket = aws_s3_bucket.c3_metadata.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "c3_metadata" {
  bucket = aws_s3_bucket.c3_metadata.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "c3_metadata" {
  bucket = aws_s3_bucket.c3_metadata.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MetadataBucketPolicy",
  "Statement": [
    {
      "Sid": "AllowController",
      "Effect": "Allow",
      "Resource" : "${aws_s3_bucket.c3_metadata.arn}/*",
      "Principal": {
        "AWS": "${module.controller_iam_role.iam_role_arn}"
      },
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Delete*"
      ]
    },
    {
      "Sid": "AllowK8sServiceAccount",
      "Effect": "Allow",
      "Resource" : "${aws_s3_bucket.c3_metadata.arn}/*",
      "Principal": {
        "AWS": "${module.evl_job_iam_role.iam_role_arn}"
      },
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Delete*"
      ]
    }
  ]
}
POLICY
}

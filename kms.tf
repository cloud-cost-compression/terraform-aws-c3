# --- kms.tf --

resource "aws_kms_key" "main" {
  description             = "C3 KMS key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.default_tags
}
resource "aws_kms_alias" "main" {
  name          = "alias/c3"
  target_key_id = aws_kms_key.main.key_id
}

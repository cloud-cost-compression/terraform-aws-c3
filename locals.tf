# --- locals.tf ---

locals {
  default_tags = {
    Project = "c3"
  }

  k8s_service_account_name = "c3"
  k8s_namespace_name       = "c3"

  c3_admin_aws_account_id = "397307921369"

  ubuntu2204_ami_id = "ami-03d04409e764f4d08"
}

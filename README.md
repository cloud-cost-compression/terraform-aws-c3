# Cloud Cost Compression (C3) Terraform module
Official Terraform module for infrastructure provisioning of the Cloud Cost Compression application. This module creates an EKS cluster with a controller EC2 instance managed by an autoscaling group. To manage EKS cluster, add your IAM users to `c3_eks_administrators` IAM group. This group can assume `c3-eks-admin` IAM role which has full admin permissions inside the C3 EKS cluster.

## Usage
### Minimum required configuration
```hcl
module "c3" {
  source  = "cloud-cost-compression/c3/aws"
  version = "~> 0.1"

  region = "eu-west-1"
  
  evl_app_version = "2.8.0"

  s3_data_read_bucket_name  = "c3-data-read-bucket-eu-west-1-181730553554"
  s3_data_write_bucket_name = "c3-data-write-bucket-eu-west-1-181730553554"
}
```

### Custom configuration
```hcl
module "c3" {
  source  = "cloud-cost-compression/c3/aws"
  version = "~> 0.1"

  vpc_cidr = "10.0.0.0/16"
  region   = "eu-west-1"
  
  controller_instance_name = "c3-ec2-controller"
  controller_instance_type = "t3.small"
  
  eks_cluster_version       = "1.27"
  eks_cluster_min_size      = 1
  eks_cluster_max_size      = 3
  eks_cluster_name          = "c3-eks-cluster"
  eks_cluster_instance_type = "t3.small"
  cluster_logs_types        = ["audit", "api", "authenticator"]
  cluster_logs_retention    = 90
  
  evl_app_version      = "2.8.0"
  evl_s3_bucket_name   = "foo"

  s3_data_read_bucket_name  = "c3-data-read-bucket-eu-west-1-181730553554"
  s3_data_write_bucket_name = "c3-data-write-bucket-eu-west-1-181730553554"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.4 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_c3_admin_iam_role"></a> [c3\_admin\_iam\_role](#module\_c3\_admin\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 5.20.0 |
| <a name="module_controller_iam_role"></a> [controller\_iam\_role](#module\_controller\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 5.20.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.15 |
| <a name="module_eks_admin_iam_role"></a> [eks\_admin\_iam\_role](#module\_eks\_admin\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 5.20.0 |
| <a name="module_evl_job_iam_role"></a> [evl\_job\_iam\_role](#module\_evl\_job\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.20.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_group.eks_access_administrator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.eks_access_administrator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.assume_eks_admin_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.c3_admin_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eks_describe_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_data_read_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_data_write_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_metadata_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.s3_data_read_bucket_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_data_write_bucket_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_s3_bucket.c3_metadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.c3_metadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.c3_metadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.c3_metadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.c3_metadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_security_group.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.eks_allow_access_from_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_ami.ubuntu2204](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_logs_retention"></a> [cluster\_logs\_retention](#input\_cluster\_logs\_retention) | Retention of EKS cluster logs (in days) | `number` | `7` | no |
| <a name="input_cluster_logs_types"></a> [cluster\_logs\_types](#input\_cluster\_logs\_types) | List of enabled logs - supported types: api, audit, authenticator | `list(string)` | <pre>[<br>  "audit",<br>  "api",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| <a name="input_controller_instance_name"></a> [controller\_instance\_name](#input\_controller\_instance\_name) | The Instance Name to use for C3 EC2 Controller Node | `string` | `"c3-ec2-controller"` | no |
| <a name="input_controller_instance_type"></a> [controller\_instance\_type](#input\_controller\_instance\_type) | The Instance Type to use for C3 Controller Node | `string` | `"t3.small"` | no |
| <a name="input_eks_cluster_instance_type"></a> [eks\_cluster\_instance\_type](#input\_eks\_cluster\_instance\_type) | Instance type of the EKS cluster | `string` | `"t3.small"` | no |
| <a name="input_eks_cluster_max_size"></a> [eks\_cluster\_max\_size](#input\_eks\_cluster\_max\_size) | Maximum number of worker nodes running in the EKS cluster | `string` | `3` | no |
| <a name="input_eks_cluster_min_size"></a> [eks\_cluster\_min\_size](#input\_eks\_cluster\_min\_size) | Minimum number of worker nodes running in the EKS cluster | `string` | `1` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster | `string` | `"c3-eks-cluster"` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Version of the EKS cluster | `string` | `"1.27"` | no |
| <a name="input_evl_app_version"></a> [evl\_app\_version](#input\_evl\_app\_version) | Version of the C3 EVL application | `string` | n/a | yes |
| <a name="input_evl_s3_bucket_name"></a> [evl\_s3\_bucket\_name](#input\_evl\_s3\_bucket\_name) | S3 bucket name where EVL dependencies are stored | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_s3_data_read_bucket_name"></a> [s3\_data\_read\_bucket\_name](#input\_s3\_data\_read\_bucket\_name) | ARN of S3 bucket for data read processing | `string` | n/a | yes |
| <a name="input_s3_data_write_bucket_name"></a> [s3\_data\_write\_bucket\_name](#input\_s3\_data\_write\_bucket\_name) | ARN of S3 bucket for data write processing | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR of C3 VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane |
| <a name="output_evl_job_iam_role_arn"></a> [evl\_job\_iam\_role\_arn](#output\_evl\_job\_iam\_role\_arn) | ARN of IAM role used by the evl job |

# --- eks-cluster.tf ---

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  create_kms_key  = false

  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.main.arn
    resources        = ["secrets"]
  }

  cluster_enabled_log_types              = var.cluster_logs_types
  cloudwatch_log_group_retention_in_days = var.cluster_logs_retention

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  create_cloudwatch_log_group = true

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks_admin_iam_role.iam_role_arn
      username = module.eks_admin_iam_role.iam_role_name
      groups   = ["system:masters"]
    },
    {
      rolearn  = module.controller_iam_role.iam_role_arn
      username = module.controller_iam_role.iam_role_name
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

    instance_types = [
      var.eks_cluster_instance_type
    ]
  }
  eks_managed_node_groups = {
    worker = {
      name     = "c3-eks-worker-node"
      min_size = var.eks_cluster_min_size
      max_size = var.eks_cluster_max_size

      subnet_ids = module.vpc.private_subnets

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            volume_type           = "gp3"
          }
        }
      }

      tags = local.default_tags
    }
  }

  tags = local.default_tags
}

resource "aws_security_group_rule" "eks_allow_access_from_controller" {
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.controller.id
  from_port                = 443
  to_port                  = 443
  description              = "Allow access from controller"
  security_group_id        = module.eks.cluster_security_group_id
}

module "eks_admin_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.20.0"

  number_of_custom_role_policy_arns = 1
  create_instance_profile           = false
  create_role                       = true
  role_requires_mfa                 = false
  role_name_prefix                  = "c3-eks-admin"
  trusted_role_arns                 = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  custom_role_policy_arns = [
    aws_iam_policy.eks_describe_cluster.arn
  ]
}

resource "aws_iam_policy" "eks_describe_cluster" {
  name_prefix = "eks_describe_cluster_policy"

  path        = "/"
  description = "Allow describing of the EKS clusters"

  policy = jsonencode({
    Statement = [
      {
        Sid    = "DescribeEKScluster"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = [
          "*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "assume_eks_admin_role" {
  name_prefix = "eks_admin_access_policy"

  path        = "/"
  description = "Allow assuming admin access to the C3 EKS clusters"

  policy = jsonencode({
    Statement = [
      {
        Sid    = "AssumeAdminRole"
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = [
          module.eks_admin_iam_role.iam_role_arn
        ]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_group" "eks_access_administrator" {
  name = "c3-eks-administrators-${var.region}"
}

resource "aws_iam_group_policy_attachment" "eks_access_administrator" {
  group      = aws_iam_group.eks_access_administrator.name
  policy_arn = aws_iam_policy.assume_eks_admin_role.arn
}

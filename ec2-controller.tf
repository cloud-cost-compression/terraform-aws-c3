# --- ec2-controller.tf ---

resource "aws_iam_policy" "controller" {
  name_prefix = "controller_policy"

  path        = "/"
  description = "IAM policy for controller"

  policy = jsonencode({
    Statement = [
      {
        Sid    = "DescribeEKScluster"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = [
          module.eks.cluster_arn
        ]
      },
      {
        Sid    = "AccessS3BucketEVL"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = [
          "arn:aws:s3:::${var.evl_s3_bucket_name}",
          "arn:aws:s3:::${var.evl_s3_bucket_name}/*"
        ]
      },
      {
        Sid    = "AccessS3bucketMetadata"
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
module "controller_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.20.0"

  number_of_custom_role_policy_arns = 2
  create_instance_profile           = true
  create_role                       = true
  role_requires_mfa                 = false
  role_name_prefix                  = var.controller_instance_name

  trusted_role_services = ["ec2.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    aws_iam_policy.controller.arn
  ]
}

resource "aws_security_group" "controller" {
  name_prefix = var.controller_instance_name

  description = "C3 EC2 controller security group"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "Allow all egress to public"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags, {
    Name = var.controller_instance_name
  })
}

resource "aws_launch_template" "controller" {
  name_prefix            = var.controller_instance_name
  image_id               = data.aws_ami.ubuntu2204.id
  instance_type          = var.controller_instance_type
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/scripts/ec2/controller/provision.sh.tftpl", {
    eks_cluster_name     = module.eks.cluster_name
    region_name          = var.region
    evl_app_version      = var.evl_app_version
    evl_s3_bucket_name   = var.evl_s3_bucket_name
    evl_job_iam_role_arn = module.evl_job_iam_role.iam_role_arn
    })
  )

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted             = true
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    arn = module.controller_iam_role.iam_instance_profile_arn
  }
  vpc_security_group_ids = [
    aws_security_group.controller.id
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(local.default_tags, {
    Name = var.controller_instance_name
  })
}
resource "aws_autoscaling_group" "controller" {
  name_prefix = var.controller_instance_name

  min_size          = 1
  max_size          = 2
  desired_capacity  = 1
  health_check_type = "EC2"

  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.controller.id
    version = aws_launch_template.controller.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.controller_instance_name
    propagate_at_launch = true
  }
}
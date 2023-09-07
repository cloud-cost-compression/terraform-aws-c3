# --- main.tf ---

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu2204" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# https://cloud-images.ubuntu.com/aws-eks/
data "aws_ami" "ubuntu2004_eks_optimized" {
  most_recent = true
  owners      = ["099720109477"] # canonical

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_${var.eks_cluster_version}/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


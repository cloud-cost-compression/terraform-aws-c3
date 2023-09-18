# --- vpc.tf ---

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "c3-vpc"

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 0), cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 50), cidrsubnet(var.vpc_cidr, 8, 51), cidrsubnet(var.vpc_cidr, 8, 52)]

  enable_ipv6             = false
  map_public_ip_on_launch = false

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  manage_default_network_acl = false

  tags = local.default_tags
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"

  tags = merge(local.default_tags, {
    Name = "c3-vpc-s3-endpoint"
  })
}

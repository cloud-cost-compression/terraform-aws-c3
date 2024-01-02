# --- vpc.tf ---

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "c3-vpc"

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 0), cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 50), cidrsubnet(var.vpc_cidr, 8, 51), cidrsubnet(var.vpc_cidr, 8, 52)]

  enable_ipv6             = false
  map_public_ip_on_launch = false

  enable_nat_gateway = var.enable_nat_gateway
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

  route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
}

resource "aws_security_group" "vpc_interface_endpoint" {
  name        = "c3-vpc-interface-endpoint-security-group"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name = "c3-vpc-interface-endpoint-security-group"
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_interface_endpoint.id,
  ]

  private_dns_enabled = true

  subnet_ids = [module.vpc.private_subnets[0]]
}
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_interface_endpoint.id,
  ]

  private_dns_enabled = true

  subnet_ids = [module.vpc.private_subnets[0]]
}
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.vpc_interface_endpoint.id,
  ]

  private_dns_enabled = true

  subnet_ids = [module.vpc.private_subnets[0]]
}

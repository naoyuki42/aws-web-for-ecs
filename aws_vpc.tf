# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = "${var.env}-vpc"
  })
}

# VPC用セキュリティグループ
module "vpc_sg" {
  source      = "./modules/security_group"
  name        = "vpc_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
  env         = var.env
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.env}-igw"
  })
}

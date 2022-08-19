# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = "${var.env}-vpc"
  })
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.env}-igw"
  })
}

# パブリックサブネット01
resource "aws_subnet" "public_01" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${var.env}-public-subnet-01"
  })
}

resource "aws_route_table_association" "public_01" {
  subnet_id      = aws_subnet.public_01.id
  route_table_id = aws_route_table.public.id
}

# パブリックサブネット02
resource "aws_subnet" "public_02" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${var.env}-public-subnet-02"
  })
}

resource "aws_route_table_association" "public_02" {
  subnet_id      = aws_subnet.public_02.id
  route_table_id = aws_route_table.public.id
}

# パブリックサブネット用ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.env}-public-route-table"
  })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# プライベートサブネット01
resource "aws_subnet" "private_01" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = merge({
    Name = "${var.env}-private-subnet-01"
  })
}

resource "aws_route_table_association" "private_01" {
  subnet_id      = aws_subnet.private_01.id
  route_table_id = aws_route_table.private.id
}

# プライベートサブネット02
resource "aws_subnet" "private_02" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.66.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = merge({
    Name = "${var.env}-private-subnet-02"
  })
}

resource "aws_route_table_association" "private_02" {
  subnet_id      = aws_subnet.private_02.id
  route_table_id = aws_route_table.private.id
}

# プライベートサブネット用ルートテーブル
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.env}-private-route-table"
  })
}

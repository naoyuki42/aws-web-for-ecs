# ドメイン
data "aws_route53_zone" "domain" {
  name = var.domain
}

# DNSレコード
resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.domain.id
  name    = data.aws_route53_zone.domain.name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# SSL証明書
resource "aws_acm_certificate" "acm" {
  domain_name               = aws_route53_record.alb.name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
    Name = "${var.env}-certificate"
  })
}

resource "aws_route53_record" "certificate_record" {
  name    = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_value]
  zone_id = data.aws_route53_zone.domain.id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_valdattion" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [aws_route53_record.certificate_record.fqdn]
}

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
  source      = "../security/security_group"
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

# ロードバランサー
resource "aws_lb" "alb" {
  name                       = "${var.env}-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.public_01.id,
    aws_subnet.public_02.id,
  ]

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]

  tags = merge({
    Name = "${var.env}-alb"
  })
}

# HTTP通信用セキュリティグループ
module "http_sg" {
  source      = "../security/security_group"
  name        = "http_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
  env         = var.env
}

# HTTPS通信用セキュリティグループ
module "https_sg" {
  source      = "../security/security_group"
  name        = "https_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
  env         = var.env
}

# HTTPからHTTPSへのリダイレクト用セキュリティグループ
module "http_redirect_sg" {
  source      = "../security/security_group"
  name        = "http_redirect_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
  env         = var.env
}

# HTTPのリスナー
resource "aws_lb_listener" "http_listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPSのリスナー
resource "aws_lb_listener" "https_listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.acm.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "これは『HTTPS』です"
      status_code  = 200
    }
  }
}

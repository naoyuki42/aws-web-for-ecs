# ロードバランサー
resource "aws_lb" "alb" {
  name               = "${var.env}-alb"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60

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
  source      = "./modules/security_group"
  name        = "http_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
  env         = var.env
}

# HTTPS通信用セキュリティグループ
module "https_sg" {
  source      = "./modules/security_group"
  name        = "https_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
  env         = var.env
}

# HTTPからHTTPSへのリダイレクト用セキュリティグループ
module "http_redirect_sg" {
  source      = "./modules/security_group"
  name        = "http_redirect_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
  env         = var.env
}

# HTTPのリスナー
resource "aws_lb_listener" "http_listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
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

  depends_on = [
    aws_acm_certificate_validation.certificate_valdattion
  ]
}

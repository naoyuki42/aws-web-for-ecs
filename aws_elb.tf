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
    module.https_sg.security_group_id,
  ]
}

# HTTP通信用セキュリティグループ
module "http_sg" {
  source      = "./modules/security_group"
  name        = "http_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

# HTTPS通信用セキュリティグループ
module "https_sg" {
  source      = "./modules/security_group"
  name        = "https_sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

# HTTPSのリスナー
resource "aws_lb_listener" "https_listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.acm_for_alb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = 404
    }
  }

  depends_on = [
    aws_acm_certificate_validation.certificate_valdattion_for_alb
  ]
}

# CloudFront用リスナールール
resource "aws_lb_listener_rule" "from_cf" {
  listener_arn = aws_lb_listener.https_listner.arn
  priority     = 100

  # TODO:カスタムヘッダーを変数で定義したい
  condition {
    http_header {
      http_header_name = "x-custom-header"
      values           = ["naoyuki42"]
    }
  }

  # TODO:ECSのデプロイまで固定値を返却する
  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "カスタムヘッダーが正常に付いていました。"
      status_code  = 200
    }
  }
}

# # ターゲットグループ
# resource "aws_lb_target_group" "target_group" {
#   name                 = "target"
#   target_type          = "ip"
#   vpc_id               = aws_vpc.vpc.id
#   port                 = 80
#   protocol             = "HTTP"
#   deregistration_delay = 300

#   health_check {
#     path                = "/"
#     healthy_threshold   = 5
#     unhealthy_threshold = 2
#     timeout             = 5
#     interval            = 30
#     matcher             = 200
#     port                = "traffic-port"
#     protocol            = "HTTP"
#   }

#   depends_on = [
#     aws_lb.alb
#   ]
# }

# # リスナールール
# resource "aws_lb_listener_rule" "listner_rule" {
#   listener_arn = aws_lb_listener.http_listner.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }

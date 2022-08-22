# ドメイン
data "aws_route53_zone" "domain" {
  name = var.domain
}

# ALB用DNSレコード
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

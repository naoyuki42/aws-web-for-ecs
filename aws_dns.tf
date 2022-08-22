# ドメイン
data "aws_route53_zone" "domain" {
  name = var.domain
}

# ALB-CloudFront用DNSレコード
resource "aws_route53_record" "record_for_cf" {
  zone_id = data.aws_route53_zone.domain.id
  name    = "api.${data.aws_route53_zone.domain.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_for_alb.domain_name
    zone_id                = aws_cloudfront_distribution.cf_for_alb.hosted_zone_id
    evaluate_target_health = false
  }
}

# ALB用DNSレコード
resource "aws_route53_record" "record_for_alb" {
  zone_id = data.aws_route53_zone.domain.id
  name    = "alb.${data.aws_route53_zone.domain.name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

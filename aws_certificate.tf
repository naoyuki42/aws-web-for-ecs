# CloudFront用の証明書の発行はバージニア北部リージョン(us-east-1)で実施
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# CloudFront用SSL証明書
resource "aws_acm_certificate" "acm_for_cf" {
  provider                  = aws.virginia
  domain_name               = "*.${data.aws_route53_zone.domain.name}"
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "certificate_valdattion_for_cf" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.acm_for_cf.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation_record.fqdn]
}

# ALB用SSL証明書
resource "aws_acm_certificate" "acm_for_alb" {
  domain_name               = "*.${data.aws_route53_zone.domain.name}"
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "certificate_valdattion_for_alb" {
  certificate_arn         = aws_acm_certificate.acm_for_alb.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation_record.fqdn]
}

# 証明書検証用DNSレコード
resource "aws_route53_record" "certificate_validation_record" {
  name = tolist(aws_acm_certificate.acm_for_alb.domain_validation_options)[0].resource_record_name
  type = tolist(aws_acm_certificate.acm_for_alb.domain_validation_options)[0].resource_record_type
  records = [
    tolist(aws_acm_certificate.acm_for_alb.domain_validation_options)[0].resource_record_value
  ]
  zone_id = data.aws_route53_zone.domain.id
  ttl     = 60
}

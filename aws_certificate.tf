# CloudFront用の証明書の発行はバージニア北部リージョン(us-east-1)で実施
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# TODO:証明書を2つのリージョンで発行したいけど出来ない
# SSL証明書
resource "aws_acm_certificate" "acm" {
  provider                  = aws.virginia
  domain_name               = aws_route53_record.alb.name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront用のSSL証明書の検証
resource "aws_route53_record" "certificate_validation_record_for_cf" {
  name = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_name
  type = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_type
  records = [
    tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_value
  ]
  zone_id = data.aws_route53_zone.domain.id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_valdattion_for_cf" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation_record_for_cf.fqdn]
}

# ALB用のSSL証明書の検証
resource "aws_route53_record" "certificate_validation_record_for_alb" {
  name = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_name
  type = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_type
  records = [
    tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_value
  ]
  zone_id = data.aws_route53_zone.domain.id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_valdattion_for_alb" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation_record_for_alb.fqdn]
}

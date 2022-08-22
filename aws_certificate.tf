# SSL証明書
resource "aws_acm_certificate" "acm" {
  domain_name               = aws_route53_record.alb.name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_record" {
  name = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_name
  type = tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_type
  records = [
    tolist(aws_acm_certificate.acm.domain_validation_options)[0].resource_record_value
  ]
  zone_id = data.aws_route53_zone.domain.id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_valdattion" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [aws_route53_record.certificate_record.fqdn]
}

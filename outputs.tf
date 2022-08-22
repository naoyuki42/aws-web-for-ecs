output "domain_name_for_alb" {
  value = aws_route53_record.record_for_alb.name
}

output "domain_name_for_cf" {
  value = aws_route53_record.record_for_cf.name
}
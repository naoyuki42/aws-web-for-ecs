output "domain_name" {
  value = aws_route53_record.alb.name
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_01_id" {
  value = aws_subnet.public_01.id
}

output "public_subnet_02_id" {
  value = aws_subnet.public_02.id
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

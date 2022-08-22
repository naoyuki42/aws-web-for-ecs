# ALB用CloudFront
resource "aws_cloudfront_distribution" "cf_for_alb" {
  enabled = true
  aliases = [
    "api.${data.aws_route53_zone.domain.name}"
  ]

  origin {
    domain_name = aws_route53_record.record_for_alb.name
    origin_id   = aws_lb.alb.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }

    # TODO:カスタムヘッダーを変数で指定したい
    custom_header {
      name  = "x-origin-header"
      value = "naoyuki42"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    target_origin_id       = aws_lb.alb.id
    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = aws_acm_certificate.acm_for_cf.arn
    ssl_support_method             = "sni-only"
  }
}

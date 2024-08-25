resource "aws_route53_record" "app" {
  zone_id = var.route53_zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.load_balancer.dns_name
    zone_id                = var.load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app_internal" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.internal_load_balancer.dns_name
    zone_id                = var.internal_load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone.zone_id
  name    = var.cdn_subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.dashboard.domain_name
    zone_id                = aws_cloudfront_distribution.dashboard.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "audio" {
  zone_id = var.route53_zone.zone_id
  name    = var.audio_subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.audio.domain_name
    zone_id                = aws_cloudfront_distribution.audio.hosted_zone_id
    evaluate_target_health = true
  }
}

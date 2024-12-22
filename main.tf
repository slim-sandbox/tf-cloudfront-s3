locals {
  alternate_domain_name = "${var.name_prefix}.sctp-sandbox.com"
}

resource "aws_s3_bucket" "static_web" {
  bucket        = "${var.name_prefix}-static-site"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_cloudfront_access" {
  bucket = aws_s3_bucket.static_web.id
  policy = data.aws_iam_policy_document.allow_cloudfront_access.json
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${aws_s3_bucket.static_web.id}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "static_web" {
  origin {
    domain_name              = aws_s3_bucket.static_web.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "origin-${aws_s3_bucket.static_web.id}"
  }

  enabled             = true
  comment             = "${var.name_prefix}'s static website using S3 and Cloudfront OAC"
  default_root_object = "index.html"

  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed_cache_optimized.id
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-${aws_s3_bucket.static_web.id}"
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  ## activity 1: default certificates
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # ## activity 2: acm certificates + custom domain
  # viewer_certificate {
  #   acm_certificate_arn = module.acm.acm_certificate_arn
  #   ssl_support_method  = "sni-only"
  # }

  # aliases = [local.alternate_domain_name]

  # ## activity 2: waf acl
  # web_acl_id = aws_wafv2_web_acl.cloudfront.arn
}

# ## activity 2: acm certificates
# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 4.0"

#   providers = {
#     aws = aws.us-east-1
#   }

#   domain_name = local.alternate_domain_name
#   zone_id     = data.aws_route53_zone.sctp_zone.id

#   validation_method = "DNS"

#   wait_for_validation = true
# }

# ## activity 2: custom domain
# resource "aws_route53_record" "www" {
#   zone_id = data.aws_route53_zone.sctp_zone.zone_id
#   name    = var.name_prefix # Bucket prefix before sctp-sandbox.com
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.static_web.domain_name
#     zone_id                = aws_cloudfront_distribution.static_web.hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# ## activity 2: waf acl
# resource "aws_wafv2_web_acl" "cloudfront" {
#   name  = "${var.name_prefix}-cloudfront-acl"
#   scope = "CLOUDFRONT"

#   provider = aws.us-east-1

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "AWS-AWSManagedRulesCommonRuleSet"
#     priority = 1
#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.name_prefix}-commonrule-metric"
#       sampled_requests_enabled   = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = false
#     metric_name                = "${var.name_prefix}-wafacl-metric"
#     sampled_requests_enabled   = false
#   }
# }

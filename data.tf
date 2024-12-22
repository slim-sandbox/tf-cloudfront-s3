data "aws_cloudfront_cache_policy" "managed_cache_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_iam_policy_document" "allow_cloudfront_access" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.static_web.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.static_web.arn]
    }
  }
}

# ## activity 2: custom domain
# data "aws_route53_zone" "sctp_zone" {
#   name = "sctp-sandbox.com"
# }
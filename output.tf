output "s3_bucket_name" {
  value = aws_s3_bucket.static_web.bucket
}

output "distribution_domain_http_url" {
  value = "http://${aws_cloudfront_distribution.static_web.domain_name}"
}

output "alternate_domain_http_url" {
  value = "http://${local.alternate_domain_name}"
}

output "distribution_domain_https_url" {
  value = "https://${aws_cloudfront_distribution.static_web.domain_name}"
}

output "alternate_domain_https_url" {
  value = "https://${local.alternate_domain_name}"
}

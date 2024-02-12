resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "origin access identity for static_web_site"
}
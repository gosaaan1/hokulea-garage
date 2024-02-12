# see => https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
resource "aws_cloudfront_distribution" "distributions" {
  for_each = var.sites

  web_acl_id = aws_wafv2_web_acl.cloudfront[each.key].arn

  origin {
    domain_name = aws_s3_bucket.origins[each.key].bucket_regional_domain_name
    origin_id   = "${each.key}-${local.account_id_hash}"

    # SEE=>https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
    s3_origin_config {
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = each.value.comment
  default_root_object = each.value.default_root_object

  logging_config {
    include_cookies = false
    bucket          = "web-access-log-${local.account_id_hash}.s3.amazonaws.com"
    prefix          = each.key
  }

  # 代替のドメイン名（公開用にドメインを取得している場合に指定）
  aliases = each.value.aliases

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#default-cache-behavior-arguments
  default_cache_behavior {
    allowed_methods  = each.value.allowed_methods
    cached_methods   = each.value.cached_methods
    target_origin_id = "${each.key}-${local.account_id_hash}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = each.value.default_ttl
    max_ttl                = each.value.max_ttl
    compress               = true
  }

  # SEE => https://aws.amazon.com/jp/cloudfront/pricing/
  price_class = "PriceClass_200"

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#restrictions-arguments
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = each.value.locations
    }
  }

  tags = {
    Environment = each.key
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#viewer-certificate-arguments
  viewer_certificate {
    # https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValues-security-policy
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl
# https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-wafv2-webacl.html

resource "aws_wafv2_web_acl" "cloudfront" {
  for_each = var.sites
  name     = "${each.key}-cloudfront"
  scope    = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "${each.key}-cloudfront-allow-addresses"
    priority = 10

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allow_addresses[each.key].arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${each.key}-cloudfront-allow-addresses"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${each.key}-cloudfront"
    sampled_requests_enabled   = false
  }
}
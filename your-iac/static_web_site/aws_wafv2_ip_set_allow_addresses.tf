# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set

resource "aws_wafv2_ip_set" "allow_addresses" {
  for_each           = var.sites
  name               = "${each.key}-allow-addresses"
  description        = "${each.key} allow addresses ip set"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = each.value.allow_addresses

  tags = {
    bill = each.key
  }
}
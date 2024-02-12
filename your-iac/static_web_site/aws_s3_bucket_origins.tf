resource "aws_s3_bucket" "origins" {
  for_each      = var.sites
  bucket        = "${each.key}-${local.account_id_hash}"
  force_destroy = true
  tags = {
    Name = each.key
  }
}

resource "aws_s3_bucket_acl" "origins" {
  for_each = var.sites
  bucket   = "${each.key}-${local.account_id_hash}"
  acl      = "private"
}

resource "aws_s3_bucket_acl" "web_access_log" {
  bucket = "web-access-log-${local.account_id_hash}"
  acl    = "private"
}

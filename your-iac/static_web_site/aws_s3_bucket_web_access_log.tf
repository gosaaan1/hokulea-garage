resource "aws_s3_bucket" "web_access_log" {
  bucket        = "web-access-log-${local.account_id_hash}"
  force_destroy = true
  tags = {
    Name = "web-access-log"
  }
}

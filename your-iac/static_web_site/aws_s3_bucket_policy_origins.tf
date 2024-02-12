resource "aws_s3_bucket_policy" "origins" {
  for_each = var.sites
  bucket   = aws_s3_bucket.origins[each.key].id
  policy   = data.aws_iam_policy_document.allow_access_from_cloudfront[each.key].json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  for_each = var.sites
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.default.id}"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.origins[each.key].arn,
      "${aws_s3_bucket.origins[each.key].arn}/*",
    ]
  }
}
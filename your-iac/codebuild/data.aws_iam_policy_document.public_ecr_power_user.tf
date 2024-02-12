data "aws_iam_policy_document" "public_ecr_power_user" {
  source_json = data.aws_iam_policy.public_ecr_power_user.policy
}

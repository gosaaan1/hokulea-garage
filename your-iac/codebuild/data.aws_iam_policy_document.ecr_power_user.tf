data "aws_iam_policy_document" "ecr_power_user" {
  source_json = data.aws_iam_policy.ecr_power_user.policy
}
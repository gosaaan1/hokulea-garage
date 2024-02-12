data "aws_iam_policy" "public_ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicPowerUser"
}

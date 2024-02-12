# SEE => https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project

resource "aws_iam_role_policy" "codebuild" {
  name   = "codebuild-policy"
  role   = aws_iam_role.codebuild.id
  policy = <<-POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Resource": [
                  "*"
              ],
              "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ]
          },
          {
              "Effect": "Allow",
              "Resource": [
                  "arn:aws:s3:::codepipeline-${data.aws_region.current.name}-*"
              ],
              "Action": [
                  "s3:PutObject",
                  "s3:GetObject",
                  "s3:GetObjectVersion",
                  "s3:GetBucketAcl",
                  "s3:GetBucketLocation"
              ]
          }
      ]
  }
  POLICY
}

resource "aws_iam_role_policy" "ecr" {
  name = "codebuild-policy-ecr"
  role = aws_iam_role.codebuild.id
  # SEE => https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/security-iam-awsmanpol.html#security-iam-awsmanpol-AmazonEC2ContainerRegistryPowerUser
  policy = data.aws_iam_policy_document.ecr_power_user.json
}

resource "aws_iam_role_policy" "public_ecr" {
  name   = "codebuild-policy-public-ecr"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.public_ecr_power_user.json
}
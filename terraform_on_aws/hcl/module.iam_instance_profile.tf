# AWS Identity and Access Management (IAM) インスタンスプロファイルを使用すると、
# アクセス許可を個々のインスタンスレベルで付与することができます。
# https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/setup-instance-permissions.html#instance-profile-add-permissions
#
# 新ポリシー AmazonSSMManagedInstanceCore がサポートされました
# https://dev.classmethod.jp/articles/not-recommended-amazonec2roleforssm/

data "aws_iam_policy" "amazon_ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "iam_instance_profile" {
  source_policy_documents = [
    data.aws_iam_policy.amazon_ssm_managed_instance.policy
  ]
}

module "iam_instance_profile_role" {
  source     = "./iam_role"
  name       = "terraform-console-role"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.iam_instance_profile.json
}

# EC2インスタンスに直接ロールは関連付けできないので、プロファイルを設定する。
resource "aws_iam_instance_profile" "this" {
  name = "terraform_profile"
  role = module.iam_instance_profile_role.iam_role_name
}
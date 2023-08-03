# PragmaticTerraformOnAWS_b5_with_cover
# 5.7 IAMロールモジュールの定義
resource "aws_iam_role" "this" {
    name = var.name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = [var.identifier]
        }
    }
}

resource "aws_iam_policy" "this" {
    name = var.name
    policy = var.policy
}

resource "aws_iam_role_policy_attachment" "this" {
    role = aws_iam_role.this.name
    policy_arn = aws_iam_policy.this.arn
}
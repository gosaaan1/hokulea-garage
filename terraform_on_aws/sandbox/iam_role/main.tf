# Attaches a Managed IAM Policy to an IAM role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

data "aws_iam_policy_document" "assume_role" {
    statement {
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = var.identifiers
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "this" {
    name = var.name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "this" {
    for_each = var.policies
    name = each.key
    policy = each.value
}

resource "aws_iam_role_policy_attachment" "this" {
    for_each = aws_iam_policy.this
    role = aws_iam_role.this.name
    policy_arn = each.value.arn
}
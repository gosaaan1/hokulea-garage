output "iam_role_arn" {
    value = aws_iam_role.this.arn
}

output "iam_role_name" {
    value = aws_iam_role.this.name
}
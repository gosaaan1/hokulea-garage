resource "aws_iam_role" "codebuild" {
  name               = "CodebuildServiceRole"
  assume_role_policy = <<-EOF
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  }
  EOF
}
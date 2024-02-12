# see => https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project

resource "aws_codebuild_project" "docker_builder" {
  for_each     = var.repositories
  name         = "docker-builder-${each.key}"
  service_role = aws_iam_role.codebuild.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild"
      stream_name = "docker-builder-${each.key}"
    }
    s3_logs {
      status = "DISABLED"
    }
  }
  source {
    type      = "CODECOMMIT"
    location  = "https://git-codecommit.${data.aws_region.current.name}.amazonaws.com/v1/repos/${each.value.repository_name}"
    buildspec = each.value.buildspec
  }
  source_version = each.value.source_version
}

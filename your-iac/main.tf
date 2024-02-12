# SEE => https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
      # 複数のプロバイダ構成
      # https://www.terraform.io/language/providers/configuration#alias-multiple-provider-configurations
      configuration_aliases = [aws.verginia]
    }
  }
}

# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.
provider "aws" {
  region = "ap-northeast-1"
}

# Additional provider configuration
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# module "codebuild" {
#   source = "./codebuild"
#   repositories = {
#     terraform-mfa = {
#       repository_name = "hokulea"
#       source_version  = "master"
#       buildspec       = "./buildspec_terraform_mfa.yml"
#     }
#   }/workspaces/hokulea/your-iac/.terraform
# }

module "static_web_sites" {
  source = "./static_web_site"
  # For CLOUDFRONT, you must create your WAFv2 resources in the US East (N. Virginia) Region, us-east-1.
  # https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-wafv2-webacl.html#aws-resource-wafv2-webacl-properties 
  providers = {
    aws = aws.virginia
  }
  sites = {
    hokulea-online-manual = {
      comment             = "hokulea online manual"
      default_root_object = "index.html"
      allowed_methods     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods      = ["GET", "HEAD"]
      default_ttl         = 3600  # 1時間
      max_ttl             = 86400 # 1日
      locations           = ["JP"]
      aliases             = []
      allow_addresses     = split(",", file("./white_ip.list"))
    },
  }
}

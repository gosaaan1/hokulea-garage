# see => https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
data "aws_region" "current" {}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.id
  security_group_ids = []

  endpoints = {
    ssm = {
      service             = "com.amazonaws.ap-northeast-1.ssm"
      # AWS のサービス にアクセスするアベイラビリティゾーンごとに 1 つのサブネットを選択します。
      subnet_ids = []
      # VPC エンドポイントのエンドポイントネットワークインターフェイスに関連付けるセキュリティグループを選択します。
      security_group_ids = []
      tags                = { Name = "ssm-vpc-endpoint" }
      # policy
    },
    ec2messages = {
      service             = "com.amazonaws.ap-northeast-1.ec2messages"
      subnet_ids = []
      security_group_ids = []
      tags                = { Name = "ec2messages-vpc-endpoint" }
      # policy
    },
    ec2 = {
      service             = "com.amazonaws.ap-northeast-1.ec2"
      subnet_ids = []
      # id address type
      security_group_ids = []
      tags                = { Name = "ec2-vpc-endpoint" }
      # policy
    },
    ssmmessages = {
      service             = "com.amazonaws.ap-northeast-1.ssmmessages"
      subnet_ids = []
      # id address type
      security_group_ids = []
      tags                = { Name = "ssmmessages-vpc-endpoint" }
      # policy
    },
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
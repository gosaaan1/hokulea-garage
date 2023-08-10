# パブリックサブネットだけ持つシンプルなネットワーク
# https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "infra-manager-vpc"
  cidr = "10.100.0.0/16"

  azs            = ["ap-northeast-1a"]
  public_subnets = ["10.100.200.0/24"]
  private_subnets = ["10.100.0.0/24"]

  enable_vpn_gateway = true
  enable_nat_gateway = true

  # デフォルトのセキュリティグループがTerraformによって上書きされるので再設定する
  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      self = true
    }
  ]

  tags = {
    name = "infra-manager"
  }
}

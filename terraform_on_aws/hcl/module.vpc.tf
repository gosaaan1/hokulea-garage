module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "infra-dev-vpc"
  cidr = "10.100.0.0/16"

  azs             = ["ap-northeast-1a"]
  private_subnets = ["10.100.1.0/24"]
  public_subnets  = ["10.100.101.0/24"]

  # 単一のNATゲートウェイを使う
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = true

  tags = {
    name = "infra-dev"
  }
}

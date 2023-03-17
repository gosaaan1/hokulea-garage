module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = local.name
  cidr   = local.vpc_cidr

  azs              = module.utils.azs2
  public_subnets   = [for k, v in module.utils.azs2 : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in module.utils.azs2 : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in module.utils.azs2 : cidrsubnet(local.vpc_cidr, 8, k + 6)]

  # https://github.com/terraform-aws-modules/terraform-aws-vpc#public-access-to-rds-instances
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

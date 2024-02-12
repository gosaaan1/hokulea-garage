# SEE => https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }
}

module "utils" {
  source = "./hokulea/utils"
}

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

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = local.name
  description = "MySQL security group."
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from HOME"
      cidr_blocks = "119.228.14.211/32"   // NOTE Check your home network.
    },
  ]

  tags = local.tags
}

module "rds-stresstest" {
  // see https://github.com/terraform-aws-modules/terraform-aws-rds
  source     = "terraform-aws-modules/rds/aws"
  identifier = local.name

  engine               = "mysql"
  engine_version       = "8.0.27"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t2.micro" # 0.017USD/H Memory 1GB, 1vCPU
  storage_encrypted    = false

  allocated_storage     = 20 # 0.09USD/GB (OUT) / None (IN)
  max_allocated_storage = 20

  publicly_accessible             = true
  db_name                         = "sbtest"
  username                        = "stresstest"
  password                        = "rdsstresstest"
  create_random_password          = false
  port                            = "3306"
  multi_az                        = false
  db_subnet_group_name            = module.vpc.database_subnet_group
  vpc_security_group_ids          = [module.security_group.security_group_id]
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true
  skip_final_snapshot             = true
  deletion_protection             = false
  parameters                      = local.mysql_parameters

  tags = local.tags
}
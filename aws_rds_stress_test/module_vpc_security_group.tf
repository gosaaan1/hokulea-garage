module "vpc_security_group" {
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
      description = "MySQL access from remote"
      cidr_blocks = var.cider_blocks
    },
  ]

  tags = local.tags
}

module "rds" {
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
  vpc_security_group_ids          = [module.vpc_security_group.security_group_id]
  enabled_cloudwatch_logs_exports = ["general", "slowquery"]
  create_cloudwatch_log_group     = true
  skip_final_snapshot             = true
  deletion_protection             = false
  parameters                      = local.mysql_parameters

  tags = local.tags
}

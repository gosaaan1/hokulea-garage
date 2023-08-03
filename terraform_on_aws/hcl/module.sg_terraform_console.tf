module "sg_terraform_console" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "terraform-console"
  description = "Security group for terraform-console"
  vpc_id      = module.vpc.vpc_id

  # ingressはなし
  # exgressは全許可
}

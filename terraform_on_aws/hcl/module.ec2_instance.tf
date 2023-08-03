module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "terraform-console"

  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.this.name
  vpc_security_group_ids = [module.sg_terraform_console.security_group_id]
  # about element() => https://qiita.com/moko_Swallows/items/e19e8eb553fa7d565bcf#elementlist-index
  subnet_id = element(module.vpc.private_subnets, 0)

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

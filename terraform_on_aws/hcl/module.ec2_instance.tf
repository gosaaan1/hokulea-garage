module "sg_ec2_instance" {
  source      = "./security_group"
  name        = "ec2-instance-sg"
  vpc_id      = module.vpc.vpc_id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "terraform-console"

  instance_type = "t2.micro"
  vpc_security_group_ids = [module.sg_ec2_instance.security_group_id]
  # about element() => https://qiita.com/moko_Swallows/items/e19e8eb553fa7d565bcf#elementlist-index
  subnet_id = element(module.vpc.public_subnets, 0)

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

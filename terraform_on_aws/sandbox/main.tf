################################################
# ネットワークはシングルAZで構成
################################################
# VPC
resource "aws_vpc" "this" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

# ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

# ルートテーブルのルート構築
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0" # VPC以外への通信はゲートウェイ経由でインターネットへ
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.100.100.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true # 割り当てたインスタンスにパブリックIPを自動的に割り当てる
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id
  #####################################################
  # EC2 Instance Connectを使いたいときは22番ポートを開ける
  #####################################################
  # see => https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/Connect-using-EC2-Instance-Connect.html
  # see => https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/aws-ip-ranges.html#filter-json-file
  # ingress {
  #   from_port = 22
  #   to_port   = 22
  #   protocol  = "tcp"
  #   cidr_blocks = [
  #   "3.112.23.0/29"]
  # }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
}

#######################################################
# セッションマネージャを使うためのEC2インスタンスプロファイル
#######################################################
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
data "aws_iam_policy_document" "AmazonSSMManagedInstanceCore" {
  source_policy_documents = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.policy,
  ]
}
module "managed_instance_role" {
  source = "./iam_role"
  name   = "managed_instance"
  identifiers = [
    "ec2.amazonaws.com" # ssmじゃなくてec2!
  ]
  policies = {
    AmazonSSMManagedInstanceCore = data.aws_iam_policy_document.AmazonSSMManagedInstanceCore.json
  }
}
resource "aws_iam_instance_profile" "managed_instance" {
  name = "managed_instance"
  role = module.managed_instance_role.iam_role_name
}
module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "terraform-console"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  iam_instance_profile   = aws_iam_instance_profile.managed_instance.name
  # IMDSv2の使用を要求し、デフォルトのホスト管理設定でマネージドインスタンスとして扱えるようにする
  # see => https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/configuring-IMDS-new-instances.html#configure-IMDS-new-instances
  # metadata_options = {
  #   HttpEndpoint = "enabled",
  #   HttpTokens   = "required"
  # }
}

########################################
# デフォルトのホスト管理設定を有効にする場合
########################################
# see => https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/managed-instances-default-host-management.html#managed-instances-default-host-management-cli
# data "aws_iam_policy" "AmazonSSMManagedEC2InstanceDefaultPolicy" {
#   arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
# }
# data "aws_iam_policy_document" "AmazonSSMManagedEC2InstanceDefaultPolicy" {
#   source_policy_documents = [
#     data.aws_iam_policy.AmazonSSMManagedEC2InstanceDefaultPolicy.policy
#   ]
# }
# module "default_ec2_instance_management_role" {
#   source = "./iam_role"
#   name   = "AWSSystemsManagerDefaultEC2InstanceManagementRole"
#   identifiers = [
#     "ssm.amazonaws.com"
#   ]
#   policies = {
#     managed_intance_policy = data.aws_iam_policy_document.AmazonSSMManagedEC2InstanceDefaultPolicy.json
#   }
# }
# # see => https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_service_setting
# resource "aws_ssm_service_setting" "EnableDefaultEC2InstanceManagement" {
#   setting_id    = "arn:aws:ssm:ap-northeast-1:525658500115:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"
#   setting_value = "AWSSystemsManagerDefaultEC2InstanceManagementRole"
# }

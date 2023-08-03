# キーペアには、プライベートキーと公開キーを含んでおり、 
# Amazon EC2 インスタンスへの接続時の身分証明に使用する、セキュリティ認証情報のセットを構成しています。
# see => https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-key-pairs.html
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "deployer-one"
  create_private_key = true
}

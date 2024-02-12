locals {
  account_id_hash = md5(data.aws_caller_identity.current.account_id)
}
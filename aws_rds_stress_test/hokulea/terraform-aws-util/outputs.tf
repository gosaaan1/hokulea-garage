output "account_id_hash" {
    description = "create hash from account id"
    value = md5(data.aws_caller_identity.current.account_id)
}

output "azs1" {
    description = "Return 1 availability zones."
    value = slice(data.aws_availability_zones.available.names, 0, 1)
}

output "azs2" {
    description = "Return 2 availability zones."
    value = slice(data.aws_availability_zones.available.names, 0, 2)
}

output "azs3" {
    description = "Return 3 availability zones."
    value = slice(data.aws_availability_zones.available.names, 0, 3)
}
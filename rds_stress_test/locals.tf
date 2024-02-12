locals {
  name = "hokulea"
  tags = {
    Name    = "Hokulea"
    Bill    = "RDSStressTest"
  }

  vpc_cidr = "10.0.0.0/16"

  mysql_parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
  ]
}
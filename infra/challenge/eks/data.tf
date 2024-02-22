data "aws_subnet" "private_subnet_1" {
  id = var.private_subnet_1
}

data "aws_subnet" "private_subnet_2" {
  id = var.private_subnet_2
}

data "aws_vpc" "lovevery_vpc"{
  id = var.aws_vpc_id
}
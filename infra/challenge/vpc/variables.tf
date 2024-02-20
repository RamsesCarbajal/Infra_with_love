variable "public_subnets_cidr" {
  type = list(any)
}

variable "private_subnets_cidr" {
  type = list(any)
}

variable "environment" {
  type = string
}

variable "cidr_block_prefix" {
  type = string
}

variable "project_name" {
  type = string
}
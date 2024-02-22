variable "environment" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_subnets" {
  type = list(string)
}

variable "aws_vpc_id" {
  type = string
}

variable "eks_ami_id" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "main_instance_type" {
  type = string
}

variable "create_alb" {
  type = string
  default = ""
}

variable "create_iam_openid"{
  type = bool
  default = true
}
variable "alb_subnets" {
  type = list(string)
  default = []
}

variable "additional_node_group"{
  type = bool
  default = false
}

variable "nodes_number" {
  type = number
  default = 2
}
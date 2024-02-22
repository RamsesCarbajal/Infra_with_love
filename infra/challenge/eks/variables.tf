variable "private_subnet_1" {
  type = string
}

variable "private_subnet_2" {
  type = string
}

variable "aws_vpc_id" {
  type = string
}

variable "environment" {
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

variable "clusters"{
  type = list(object({
    ClusterName = string
    AlbName     = string
    NodesNumber = number
    Operation   = string
  }))
}

variable "alb_subnets"{
  type = list(string)
}

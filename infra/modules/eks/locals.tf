locals {
  create_alb_flag = var.create_alb == "" ? 0 :1
}
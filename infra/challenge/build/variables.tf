variable "environment" {
  type = string
}
variable "aws_account" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "aws_profile" {
  type = string
}
variable "force_image_rebuild" {
  type    = bool
  default = false
}
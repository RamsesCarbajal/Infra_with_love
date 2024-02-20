module "vpc_configuration" {
  source = "../../modules/vpc"
  public_subnets_cidr = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  environment = var.environment
  cidr_block_prefix = var.cidr_block_prefix
  project_name= var.project_name
}

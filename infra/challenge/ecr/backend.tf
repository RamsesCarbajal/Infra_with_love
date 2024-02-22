terraform {
  backend "s3" {
    bucket         = "rcarb-love-infra"
    key            = "lovevery/ecr/vpc.tfstate"
    region         = "us-east-2"
    dynamodb_table = "lovevery-state"
    profile        = "lovevery"
  }
}

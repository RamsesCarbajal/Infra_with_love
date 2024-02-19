resource "aws_ecr_repository" "rails_repo" {
  name                 = "rails-repo-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
locals {


  # ECR docker registry URI
  ecr_reg   = "${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com"

  ecr_repo  = "rails-repo-${var.environment}"    # ECR repo name
  image_tag = "latest"  # image tag

  dkr_img_src_path = "${path.module}/../../../rails/hello_world"


  dkr_build_cmd = <<-EOT
      docker build -t ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag}
            -f ${local.dkr_img_src_path}/Dockerfile .

        aws --profile ${var.aws_profile} ecr get-login-password --region ${var.aws_region} |
            docker login --username AWS --password-stdin ${local.ecr_reg}

        docker push ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag}
    EOT

}
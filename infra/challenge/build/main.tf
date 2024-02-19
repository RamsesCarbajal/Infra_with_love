# local-exec for build and push of docker image
resource "null_resource" "build_push_dkr_img" {
  triggers = {
    detect_docker_source_changes = timestamp()
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd
  }
}

output "trigged_by" {
  value = null_resource.build_push_dkr_img.triggers
}
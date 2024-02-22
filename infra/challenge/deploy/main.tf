resource "helm_release" "rails-app" {
  name  = "local-${var.environment}"
  chart = "${path.module}/../../../k8s/helm-rails/"
  values = [
    "${file("${path.module}/../../../k8s/helm-rails/values.yaml")}",
    "${file("${path.module}/../../../k8s/helm-rails/environments/${var.environment}.yaml")}"
  ]
}
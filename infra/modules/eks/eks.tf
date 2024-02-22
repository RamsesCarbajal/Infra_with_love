data "aws_region" "current" {}

data "external" "thumbprint" {
  program = ["${path.module}/thumbprint.sh", data.aws_region.current.name]
}

#### EKS

resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.eks_cluster_name}-${var.environment}"
  role_arn = aws_iam_role.eks-iam-role.arn
  version  = var.eks_version #"1.27"

  vpc_config {
    subnet_ids              = var.eks_subnets
    security_group_ids      = [aws_security_group.eks-worker_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
    ip_family = "ipv4"
  }

  depends_on = [
    aws_iam_role.eks-iam-role,
  ]
  tags = {
    project = "${var.eks_cluster_name}-${var.environment}"
  }
}

### OIDC config
resource "aws_iam_openid_connect_provider" "cluster" {
  count = var.create_iam_openid ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = aws_eks_cluster.eks-cluster.identity.0.oidc.0.issuer
  tags = {
    project = "${var.eks_cluster_name}-${var.environment}"
  }
}
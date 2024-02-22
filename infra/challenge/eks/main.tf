locals {
  flat_clusters = {
    for cluster in var.clusters :
    cluster.ClusterName => cluster
  }
}


module "insulet-eks" {
  source = "../../modules/eks/"
  for_each = local.flat_clusters
  environment        = var.environment
  eks_cluster_name   = each.value.ClusterName
  eks_subnets        = [data.aws_subnet.private_subnet_1.id, data.aws_subnet.private_subnet_2.id]
  alb_subnets        = var.alb_subnets
  aws_vpc_id         = data.aws_vpc.lovevery_vpc.id
  eks_ami_id         = var.eks_ami_id
  eks_version        = var.eks_version
  main_instance_type = var.main_instance_type
  create_alb         = each.value.AlbName
  nodes_number       = each.value.NodesNumber
}
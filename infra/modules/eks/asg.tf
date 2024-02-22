resource "aws_eks_node_group" "worker-node-group" {
  count           = 0
  cluster_name    = "${var.eks_cluster_name}-${var.environment}"
  node_group_name = "${var.eks_cluster_name}-${var.environment}-general-node-group"
  node_role_arn   = aws_iam_role.worker-nodes-role.arn
  subnet_ids      = var.eks_subnets
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
  ]
}

resource "aws_eks_node_group" "worker-node-custom-group" {
  cluster_name    = "${var.eks_cluster_name}-${var.environment}"
  node_group_name = "${var.eks_cluster_name}-${var.environment}-general-node-group-custom"
  node_role_arn   = aws_iam_role.worker-nodes-role.arn
  subnet_ids      = var.eks_subnets

  scaling_config {
    desired_size = var.nodes_number
    max_size     = var.nodes_number
    min_size     = var.nodes_number
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_eks_cluster.eks-cluster,
  ]
  launch_template {
    name    = aws_launch_template.eks_cluster_tainted_worker_node_launch_config.name
    version = aws_launch_template.eks_cluster_tainted_worker_node_launch_config.latest_version
  }
}


resource "aws_launch_template" "eks_cluster_tainted_worker_node_launch_config" {
  name = "${var.eks_cluster_name}-${var.environment}-lauch-template"

  network_interfaces {
    security_groups       = [aws_security_group.eks-worker_sg.id]
    delete_on_termination = true
    device_index          = 0
  }

  metadata_options {
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  image_id      = var.eks_ami_id
  #instance_type = "r6g.medium"
  instance_type = var.main_instance_type
  user_data = base64encode(<<EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=${aws_eks_cluster.eks-cluster.certificate_authority.0.data}
API_SERVER_URL=${aws_eks_cluster.eks-cluster.endpoint}
K8S_CLUSTER_DNS_IP="172.20.0.10"
/etc/eks/bootstrap.sh ${aws_eks_cluster.eks-cluster.name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${var.eks_ami_id},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${var.eks_cluster_name}-${var.environment}-general-nodes --max-pods=58' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP --use-max-pods false

--//--
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "locust-general-nodes"
      project = "eks-${var.eks_cluster_name}-${var.environment}"
    }
  }
}

resource "aws_eks_node_group" "worker-agent-node-group" {
  count           = var.additional_node_group ? 1:0
  cluster_name    = "${var.eks_cluster_name}-${var.environment}"
  node_group_name = "${var.eks_cluster_name}-${var.environment}-agent-nodes"
  node_role_arn   = aws_iam_role.worker-nodes-role.arn
  subnet_ids      = var.eks_subnets

  scaling_config {
    desired_size = var.nodes_number
    max_size     = var.nodes_number
    min_size     = var.nodes_number
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_eks_cluster.eks-cluster,
  ]
  launch_template {
    name    = aws_launch_template.eks_cluster_tainted_worker_agent_node_launch_config[0].name
    version = aws_launch_template.eks_cluster_tainted_worker_agent_node_launch_config[0].latest_version
  }
}


resource "aws_launch_template" "eks_cluster_tainted_worker_agent_node_launch_config" {
  count           = var.additional_node_group ? 1:0
  name = "${var.eks_cluster_name}-${var.environment}-agent-lauch-template"

  network_interfaces {
    security_groups       = [aws_security_group.eks-worker_sg.id]
    delete_on_termination = true
    device_index          = 0
  }

  metadata_options {
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  image_id      = var.eks_ami_id
  #instance_type = "r6g.medium"
  instance_type = var.main_instance_type
  user_data = base64encode(<<EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=${aws_eks_cluster.eks-cluster.certificate_authority.0.data}
API_SERVER_URL=${aws_eks_cluster.eks-cluster.endpoint}
K8S_CLUSTER_DNS_IP="172.20.0.10"
/etc/eks/bootstrap.sh ${aws_eks_cluster.eks-cluster.name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${var.eks_ami_id},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${var.eks_cluster_name}-${var.environment}-agent-nodes --max-pods=58' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP --use-max-pods false

--//--
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "jenkins-agent-nodes"
      project = "eks-${var.eks_cluster_name}-${var.environment}"
    }
  }
}
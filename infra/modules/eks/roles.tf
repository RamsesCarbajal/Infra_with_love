## Role Creation

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks-iam-role-document" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "eks-iam-role" {
  name = "${var.eks_cluster_name}-${var.environment}-eks-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.eks-iam-role-document.json
}


resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-iam-role.name
}

data "aws_iam_policy_document" "worker-nodes-role-document" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "worker-nodes-role" {
  name = "${var.eks_cluster_name}-${var.environment}-eks--nodes-role"
  assume_role_policy = data.aws_iam_policy_document.worker-nodes-role-document.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEFSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.worker-nodes-role.name
}

##operation

data "aws_iam_policy_document" "node-custom-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*",
                 "dynamodb:*",
                 "ec2:*",
                 "iam:*",
                 "autoscaling:*",
                 "dynamodb:*",
                 "dynamodb:*",
                 "secretsmanager:*"
                ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "node-custom-policy" {
  name = "${var.eks_cluster_name}-${var.environment}-s3-node-role"
  role = aws_iam_role.worker-nodes-role.id
  policy = data.aws_iam_policy_document.node-custom-policy-document.json
}

##### pod roles

data "aws_iam_policy_document" "pod-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [format(
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:%s",
        replace(
          "${aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer}",
          "https://",
          "oidc-provider/"
        )
      )]
    }
    condition {
      test   = "StringEquals"
      values = ["system:serviceaccount:default:rails",]
      variable = format(
        "%s:sub",
        trimprefix(
          "${aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer}",
          "https://"
        )
      )
    }
    condition {
      test   = "StringEquals"
      values = ["sts.amazonaws.com"]
      variable = format(
        "%s:aud",
        trimprefix(
          "${aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer}",
          "https://"
        )
      )
    }
  }
}



resource "aws_iam_role" "pod-role" {
  name               = "${var.eks_cluster_name}-${var.environment}-pod-role"
  assume_role_policy = data.aws_iam_policy_document.pod-role-policy.json
}

data "aws_iam_policy_document" "pod-s3-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pod-s3-policy" {
  name = "${var.eks_cluster_name}-${var.environment}-s3-pod-role"
  role = aws_iam_role.pod-role.id
  policy = data.aws_iam_policy_document.pod-s3-policy-document.json
}

data "aws_iam_policy_document" "pod-dynamodb-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pod-dynamodb-policy" {
  name = "${var.eks_cluster_name}-${var.environment}-dynamodb-pod-role"
  role = aws_iam_role.pod-role.id
  policy = data.aws_iam_policy_document.pod-dynamodb-policy-document.json
}

data "aws_iam_policy_document" "pod-role-document" {
  statement {
    effect    = "Allow"
    actions   = ["eks:*"]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "eks-pod-role" {
  name   = "${var.eks_cluster_name}-${var.environment}-eks-pod-role"
  role   = aws_iam_role.pod-role.id
  policy = data.aws_iam_policy_document.pod-role-document.json
}

data "aws_iam_policy_document" "ec2-pod-role-document" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ec2-pod-role" {
  name   = "${var.eks_cluster_name}-${var.environment}-ec2-pod-role"
  role   = aws_iam_role.pod-role.id
  policy = data.aws_iam_policy_document.ec2-pod-role-document.json
}

data "aws_iam_policy_document" "iam-pod-role-document" {
  statement {
    effect = "Allow"
    actions = [
      "iam:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "iam-pod-role" {
  name   = "${var.eks_cluster_name}-${var.environment}-iam-pod-role"
  role   = aws_iam_role.pod-role.id
  policy = data.aws_iam_policy_document.iam-pod-role-document.json
}

data "aws_iam_policy_document" "cust-pod-role-document" {
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:*",
      "autoscaling:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cust-pod-role" {
  name   = "${var.eks_cluster_name}-${var.environment}-cust-pod-role"
  role   = aws_iam_role.pod-role.id
  policy = data.aws_iam_policy_document.cust-pod-role-document.json
}
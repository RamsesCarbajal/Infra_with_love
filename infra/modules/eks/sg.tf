resource "aws_security_group" "eks-worker_sg" {
  name        = "${var.eks_cluster_name}-${var.environment}-eks-worker"
  description = "allow traffic to eks-worker"
  vpc_id      = var.aws_vpc_id

  tags = {
    project = "eks-${var.eks_cluster_name}-${var.environment}"
    Name    = "${var.eks_cluster_name}-${var.environment}-eks-worker"

  }
}

resource "aws_security_group_rule" "eks-worker_sg_income_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks-worker_sg.id
}

resource "aws_security_group_rule" "eks-worker_sg_outcome" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks-worker_sg.id
}
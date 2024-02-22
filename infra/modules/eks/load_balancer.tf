data "aws_elb_service_account" "current" {
}


data "aws_iam_policy_document" "alb_logs" {
  count = local.create_alb_flag
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_elb_service_account.current.arn,
      ]
    }
    resources = [
      "${aws_s3_bucket.alb_bucket[0].arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  count = local.create_alb_flag
  bucket = aws_s3_bucket.alb_bucket[0].id
  policy = data.aws_iam_policy_document.alb_logs[0].json
}
#internal-cumulus-

resource "aws_s3_bucket" "alb_bucket" {
  count = local.create_alb_flag
  bucket = "${replace(var.eks_cluster_name, "_", "-")}-${var.environment}-alb-logs"
  force_destroy = true
  tags = {
    Name = "${replace(var.eks_cluster_name, "_", "-")}-${var.environment}-alb-logs"
  }
}




resource "aws_security_group" "alb_sg" {
  count = local.create_alb_flag
  name        = "${replace(var.eks_cluster_name, "_", "-")}-${var.environment}-eks-poc"
  description = "allow traffic to loadbalancer"
  vpc_id      = var.aws_vpc_id

  tags = {
    project = "eks-${replace(var.eks_cluster_name, "_", "-")}-${var.environment}"
  }
}

resource "aws_security_group_rule" "eks-node_sg_income_http" {
  count = local.create_alb_flag
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["192.150.50.100/32"]
  security_group_id = aws_security_group.alb_sg[0].id
}

resource "aws_security_group_rule" "eks-node_sg_outcome" {
  count = local.create_alb_flag
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg[0].id
}

resource "random_integer" "random_alb_number" {
  count = local.create_alb_flag
  min = 1
  max = 500000
}

resource "aws_lb" "lovevery-alb" {
  count = local.create_alb_flag
  name               = "${var.create_alb}-${random_integer.random_alb_number[0].result}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg[0].id]
  subnets            = var.alb_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_bucket[0].id
    prefix  = "${var.eks_cluster_name}-${var.environment}-alb-poc"
    enabled = true
  }
}

resource "aws_lb_target_group" "locust-tg" {
  count = local.create_alb_flag
  name     = "${replace(replace(var.eks_cluster_name, "_", "-"),"internal-cumulus-" ,"")}-${var.environment}-tg"
  port     = 30010
  protocol = "HTTP"
  vpc_id   = var.aws_vpc_id
  health_check {
    path = "/"
  }
}

#data "aws_acm_certificate" "issued" {
#  domain   = "*.omnipodapps.com"
#  statuses = ["ISSUED"]
#}

resource "aws_alb_listener" "https" {
  count = local.create_alb_flag
  load_balancer_arn = aws_lb.lovevery-alb[0].arn
  port              = "80"
  protocol          = "HTTP"
  #certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    #target_group_arn = aws_lb_target_group.eks-nodes.arn
    target_group_arn = aws_lb_target_group.locust-tg[0].arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "locust-attach" {
  count = local.create_alb_flag
  autoscaling_group_name = aws_eks_node_group.worker-node-custom-group.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.locust-tg[0].arn
}
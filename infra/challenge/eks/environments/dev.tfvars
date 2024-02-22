private_subnet_1 = "subnet-0c980bb22ec8834c9"
private_subnet_2 = "subnet-07a26df2b7748218a"
aws_vpc_id       = "vpc-051a9fd851efc651d"
environment      = "devops"
eks_ami_id       = "ami-0a6f1a80e716e19b1"
eks_version      = "1.27"
main_instance_type = "t3.medium"

clusters=[ { "Operation": "Ready", "ClusterName": "lovevery", "NodesNumber": "2", "AlbName": "lovevery" } ]
alb_subnets=["subnet-035b5fa5aa75c0f1f","subnet-0d3ab5aeb9b598477"]

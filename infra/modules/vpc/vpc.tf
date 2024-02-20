#name     = "${var.eks_cluster_name}-${var.environment}"
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block_prefix}.0.0/16"
  #cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    project = "${var.project_name}-${var.environment}"
    Name    = "${var.project_name}-${var.environment}-vpc"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
}

data "aws_availability_zones" "available" {}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.cidr_block_prefix}.${10 + count.index}.0/24"
  availability_zone       = var.public_subnets_cidr[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index}"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.cidr_block_prefix}.${20 + count.index}.0/24"
  availability_zone       = var.private_subnets_cidr[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet_${count.index}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
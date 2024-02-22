output "locust_alb" {
  value = aws_lb.lovevery-alb[*].dns_name
}
output "load_balancer_dns_name" {
  description = "Load Balancer DNS Name"
  value = aws_lb.cloudLoadBalancer.dns_name
}


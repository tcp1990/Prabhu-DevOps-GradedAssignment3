# ALB DNS is generated dynamically, return URL so that it can be used
output "url" {
  value = "http://${aws_lb.this.dns_name}/"
}
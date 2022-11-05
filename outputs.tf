output "alb_dns" {
  description = "The load balancer's dns name"
  value       = aws_lb.production.dns_name
}

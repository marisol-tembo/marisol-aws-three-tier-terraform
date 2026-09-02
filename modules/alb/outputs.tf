output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_name" {
  description = "Name of the ALB target group"
  value       = aws_lb_target_group.app.name
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch dimensions"
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch dimensions"
  value       = aws_lb_target_group.app.arn_suffix
}

output "tls_cert_pem" {
  description = "TLS certificate for app tier nginx (matches ALB backend cert)"
  value       = tls_self_signed_cert.app.cert_pem
  sensitive   = true
}

output "tls_key_pem" {
  description = "TLS private key for app tier nginx"
  value       = tls_private_key.app.private_key_pem
  sensitive   = true
}

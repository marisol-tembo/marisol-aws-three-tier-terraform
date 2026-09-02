output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "HTTP URL for the application"
  value       = "http://${module.alb.alb_dns_name}"
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}

output "db_endpoint" {
  description = "RDS endpoint (private, app-tier access only)"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "cloudwatch_alarm_names" {
  description = "CloudWatch alarm names"
  value       = module.monitoring.alarm_names
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs"
  value       = module.vpc.private_db_subnet_ids
}

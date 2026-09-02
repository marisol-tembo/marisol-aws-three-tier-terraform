output "user_data" {
  description = "Bootstrap script to install and run the web application"
  value       = local.user_data
  sensitive   = true
}

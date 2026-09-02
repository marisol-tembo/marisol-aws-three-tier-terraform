variable "name" {
  description = "Name prefix for compute resources"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID for application servers"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum ASG size"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum ASG size"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired ASG capacity"
  type        = number
  default     = 1
}

variable "db_endpoint" {
  description = "RDS endpoint hostname"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "tls_cert_pem" {
  description = "TLS certificate PEM for nginx HTTPS"
  type        = string
  sensitive   = true
}

variable "tls_key_pem" {
  description = "TLS private key PEM for nginx HTTPS"
  type        = string
  sensitive   = true
}

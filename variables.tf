variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "three-tier"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "appuser"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ RDS (increases cost)"
  type        = bool
  default     = false
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the application tier"
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

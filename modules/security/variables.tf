variable "name" {
  description = "Name prefix for security group resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for restricted egress rules"
  type        = string
}

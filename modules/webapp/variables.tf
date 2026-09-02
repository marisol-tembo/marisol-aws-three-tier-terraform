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
  description = "TLS certificate PEM for nginx HTTPS on app instances"
  type        = string
  sensitive   = true
}

variable "tls_key_pem" {
  description = "TLS private key PEM for nginx HTTPS on app instances"
  type        = string
  sensitive   = true
}

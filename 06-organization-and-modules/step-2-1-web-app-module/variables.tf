# General variables

variable "region" {
  description = "Default region for provider"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the web application"
  type        = string
  default     = "web-app"
}

variable "environment_name" {
  description = "Deployment environment (dev/staging/production)"
  type        = string
  default     = "dev"
}

# EC2 variables

variable "ami" {
  description = "Amazon machine image to use for EC2 instance"
  type        = string
  default     = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# S3 variables

variable "bucket_name" {
  description = "Name of S3 bucket for the application to store data in"
  type        = string
}

# # Route 53 Variables

# variable "create_dns_zone" {
#   description = "If true, create new route53 zone, if false read existing route53 zone"
#   type        = bool
#   default     = false
# }

# variable "domain" {
#   description = "Domain for website"
#   type        = string
# }

# RDS variables

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "db_user" {
  description = "Username for DB"
  type        = string
}

variable "db_pass" {
  description = "Password for DB"
  type        = string
  sensitive   = true
}

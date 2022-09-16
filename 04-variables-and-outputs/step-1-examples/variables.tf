# should specify optional vs required

variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
}

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

variable "db_user" {
  description = "username for database"
  type        = string
  default     = "foo"
}

variable "db_pass" {
  description = "password for database"
  type        = string
  # The following statement ensures that, when we run
  # ```
  # terraform apply \
  #     -var="db_user=myuser" \
  #     -var="db_pass=SOMETHING_SUPER_SECURE_TO_BE_TREATED_AS_CONFIDENTIAL_INFORMATION"
  # ```,
  # the Terraform CLI will not echo its value out into the terminal.
  sensitive = true
}

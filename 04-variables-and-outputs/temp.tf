# A variable of the following type is accessed via
# `var.<name>`
variable "intance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

# A variable of the following type is accessed via
# `local.<name>`
# (Note the singular vs the plural forms!)
locals {
  service_name = "My Service"
  owner        = "XYZ Corporation"
}

# A variable of the following type is accessed via
# [tbd]
output "instance_ip_addr" {
  value = aws_instance.instance.public_ip
}

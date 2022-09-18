# Notice that
# the different portions of the [resources] architecture are broken up
# into individual Terraform configuration files.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

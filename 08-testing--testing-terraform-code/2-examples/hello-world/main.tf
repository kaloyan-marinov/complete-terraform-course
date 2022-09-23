# This is a working example of consuming the `../1-modules/hello-world` module
# (
# so that anyone coming into this repository can see,
# "Oh, here are the different variables that I need to set,
# and how I would actually use this."
# ).
terraform {
  backend "s3" {
    bucket         = "s3-bucket-terraform-state-for-my-web-app"
    key            = "08-testing--testing-terraform-code"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-table-terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Reference our module
# - since it's in this same filesystem! -
# with [a] relative path.
module "web_app" {
  source = "../../1-modules/hello-world"
}

# (Consume the referenced module's single output in order to)
# Endow the current file/config with output( variable)s of its own.
output "instance_ip_addr" {
  value = module.web_app.instance_ip_addr
}

output "url" {
  value = "http://${module.web_app.instance_ip_addr}:8080"
}

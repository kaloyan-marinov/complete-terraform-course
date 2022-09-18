# This _one_ file shows how to
# consume our `step-2-1-web-app-module`
# and deploy _two_ different copies of it.

terraform {
  # The following block assumes that
  # an S3 bucket and DynamoDB table have already been set up,
  # as is made possible by `03-basics--basic-terraform-usage/step-1-aws-backend/`.
  backend "s3" {
    bucket         = "s3-bucket-terraform-state-for-my-web-app"
    key            = "06-organization-and-modules/step-2-1-web-app-module/terraform.tfstate"
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

# Make this configuration require that
# 2 different variables should be passed in.
variable "db_pass_1" {
  description = "password for database #1"
  type        = string
  sensitive   = true
}

variable "db_pass_2" {
  description = "password for database #2"
  type        = string
  sensitive   = true
}

module "web_app_1" {
  source = "../step-2-1-web-app-module"

  # Input variables
  bucket_name = "1-s3-bucket--06-organization-and-modules--step-2-2-web-app"
  # domain = "xyz-corporation.com"
  app_name         = "web-app-1"
  environment_name = "production"
  instance_type    = "t2.small"
  # create_dns_zone = true
  db_name = "webapp1db"
  db_user = "foo"
  db_pass = var.db_pass_1
}

module "web_app_2" {
  source = "../step-2-1-web-app-module"

  # Input variables
  bucket_name = "2-s3-bucket--06-organization-and-modules--step-2-2-web-app"
  # domain = "another-xyz-corporation.com"
  app_name         = "web-app-2"
  environment_name = "production"
  instance_type    = "t2.small"
  # create_dns_zone = true
  db_name = "webapp2db"
  db_user = "bar"
  db_pass = var.db_pass_2
}

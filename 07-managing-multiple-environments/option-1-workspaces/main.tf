terraform {
  # The following block assumes that
  # an S3 bucket and DynamoDB table have already been set up,
  # as is made possible by `03-basics--basic-terraform-usage/step-1-aws-backend/`.
  backend "s3" {
    bucket         = "s3-bucket-terraform-state-for-my-web-app"
    key            = "07-managing-multiple-environments/option-1-workspaces/terraform.tfstate"
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

variable "db_pass" {
  description = "password for database"
  type        = string
  sensitive   = true
}

locals {
  environment_name = terraform.workspace
}

module "web_app" {
  source = "../../06-organization-and-modules/step-2-1-web-app-module"

  # Input variables
  # bucket_name = "1-s3-bucket--07-managing-multiple-environments--option-1-workspaces-${local.environment_name}"
  bucket_name = "07-managing-multiple-environments--optn-1-workspaces-${local.environment_name}"
  # domain = "xyz-corporation.com"
  environment_name = local.environment_name
  instance_type    = "t2.small"
  # create_dns_zone = terraform.workspace == "production" ? true : false
  db_name = "${local.environment_name}mydb"
  db_user = "foo"
  db_pass = var.db_pass
}

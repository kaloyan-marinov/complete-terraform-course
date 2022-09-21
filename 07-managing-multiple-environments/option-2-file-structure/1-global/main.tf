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

# # A Route53 zone is to be shared across the `staging` and `production` environments.
# resource "aws_route53_zone" "primary" {
#   name = "xyz-corporation.com"
# }

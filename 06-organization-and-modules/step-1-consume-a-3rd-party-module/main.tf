# `consul` is another Hashicorp tool.
# Here, we deploy the `consul` tool
# by consuming a 3rd-party module,
# (which is also called `consul`
# and) which is available via the Terraform registry.
#
# FYI:
# `consul` is a tool/system
# for automating a lot of the network set-up and discovery
# if you have many different services.

terraform {
  # The following block assumes that
  # an S3 bucket and DynamoDB table have already been set up,
  # as is made possible by `03-basics--basic-terraform-usage/step-1-aws-backend/`.
  backend "s3" {
    bucket         = "s3-bucket-terraform-state-for-my-web-app"
    key            = "06-organization-and-modules/step-1-consume-a-3rd-party-module/terraform.tfstate"
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

# Reference the `consul` module via the GitHub repository,
# which the module is stored in.
#########################################################################
##
## NOTE:
## If you are deploying this in your production setup,
## follow the instructions in the GitHub repo on how to customize things.
##
## Here, we are going to be deploying with the defaults,
## as a mere demonstration of the power of modules.
##
## REPO: https://github.com/hashicorp/terraform-aws-consul
##
#########################################################################
module "consul" {
  source = "git@github.com:hashicorp/terraform-aws-consul.git"
}

terraform {
  # (sub-step 1)
  # Without configuring a remote backend,
  # issue
  #   ```
  #   cd 03-basics--basic-terraform-usage/step-1-aws-backend/
  #
  #   terraform apply
  #   ```
  # which will cause
  # (a) Terraform to default to a local backend,
  # (b) the AWS resources declared below
  #     to be provisioned within the authenticated AWS account
  #     and
  #     to be recorded within the local Terraform state file.

#   # (sub-step 2)
#   # Uncomment the following block of code,
#   # and switch from a local backend to an AWS remote backend by re-issuing
#   #   ```
#   #   terraform init
#   #   ```
#   backend "s3" {
#     # The value on the next line needs to match the S3-bucket name specified below.
#     bucket         = "s3-bucket-terraform-state-for-my-web-app"
#     key            = "tf-infra/terraform.tfstate"
#     region         = "us-east-1"
#     # The value on the next line needs to match
#     # the DynamoDB-table name specified below.
#     dynamodb_table = "dynamodb-table-terraform-state-locking"
#     encrypt        = true
#   }


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

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "s3-bucket-terraform-state-for-my-web-app"
  force_destroy = true
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "dynamodb-table-terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  # The following is a key attribute,
  # whose value needs to match exactly in order for this to work.
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  # Skip configuring a remote backend,
  # which will cause Terraform to default to a local backend.

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
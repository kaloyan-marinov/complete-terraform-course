terraform {
  backend "s3" {
    bucket         = "s3-bucket-terraform-state-for-my-web-app"
    key            = "04-variables-and-outputs/step-1-examples/terraform.tfstate"
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

# A variable of the following type is accessed via
# `local.<name>`
# (Note the singular vs the plural forms!)
locals {
  extra_tag = "extra-tag"
}

resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra_tag
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "12.4"
  instance_class    = "db.t2.micro"
  name              = "mydb"
  # The next two lines specify the credentials for accessing the DB.
  # (
  # "We could put them in 'the `tfvars` file',
  # but because they're sensitive, we likely want to pass them in at runtime."
  # An example of how they can be passed in at runtime is included in `variables.tf`.
  #
  # However, I must note that the `.gitignore` file,
  # which was obtained by downloading the contents of the file at
  # https://github.com/github/gitignore/blob/main/Terraform.gitignore ,
  # marks 'the `tfvars` file' as one of the files,
  # which should not be committed to (source) version control;
  # correspondingly, I must encourage you to read, think about, and understand
  # the relevant comment within the `.gitignore` file.
  # )
  username            = var.db_user
  password            = var.db_password
  skip_final_snapshot = true
}

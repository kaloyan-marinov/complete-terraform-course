terraform {
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

# Cf. https://registry.terraform.io/providers/aaronfeng/aws/latest/docs/resources/instance
resource "aws_instance" "example" {
  # The following value specifies
  # which Amazon Machine Image (AMI) should be used (as the basis)
  # for creating an EC2 virtual machine instance.
  # (A concrete AMI specifies not only an operating system,
  # but also the full set of information required to create an EC2 instance.)
  ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type = "t2.micro"
}
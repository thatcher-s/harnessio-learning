terraform {
  required_version = "~> 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.43"
    }
  }
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}


provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key

  default_tags {
    tags = {
      CreatedBy = "terraform"
    }
  }
}

resource "aws_s3_bucket" "resource" {
  bucket = "demo-harness-terraform-bucket"
}
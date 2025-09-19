terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 5.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id 
  versioning_configuration {
    status = "Enabled"
  }
}


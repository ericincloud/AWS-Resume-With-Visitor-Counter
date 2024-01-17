provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" " "s3bucket" {
  bucket = "s3buckettesting12234234"
  acl    = "private"  # Access control list, adjust as needed

  tags = {
    Name        = "ExampleS3Bucket"
    Environment = "Production"
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.example.bucket
    target_prefix = "logs/"
  }

  lifecycle {
    prevent_destroy = false  # Set to true to prevent accidental deletion
  }

  # Add other configurations as needed
}

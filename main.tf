provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "test23423" {
  bucket = "newtestbucket3244234"
  acl    = "private"  # Access control list, adjust as needed

  tags = {
    Name        = "ExampleS3Bucket"
    Environment = "Production"
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false  # Set to true to prevent accidental deletion
  }

  # Add other configurations as needed
}

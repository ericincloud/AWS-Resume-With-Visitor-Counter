provider "aws" {
  region = "us-west-1" # Change to your desired AWS region
}

   backend "s3" {
       bucket = "[tester]"
       region = "west-us-1"
   }
}

# DynamoDB Table
resource "aws_dynamodb_table" "example" {
  name           = "example_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}




provider "aws" {
  region = "us-west-1"  # Change to your desired AWS region
}

# S3 Bucket for Static Site
resource "aws_s3_bucket" "static_site" {
  bucket = "ericincloud.com"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "visitor_table" {
  name           = "VisitorTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Visitors"
  range_key      = "TotalVisitors"
  attribute {
    name = "Visitors"
    type = "S"
  }
  attribute {
    name = "TotalVisitors"
    type = "N"
  }
}

# Lambda Functions
resource "aws_lambda_function" "visitor_counter" {
  function_name = "VisitorCounter"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "VisitorCountLambda.zip"  # Specify the path to your Lambda code

  source_code_hash = filebase64("VisitorCountLambda.zip")
}

resource "aws_lambda_function" "retrieve_visitor_count" {
  function_name = "RetrieveVisitorCount"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "RetrieveVisitorCountLambda.zip"  # Specify the path to your Lambda code

  source_code_hash = filebase64("RetrieveVisitorCountLambda.zip")
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "ericincloud" {
  origin {
    domain_name = ericincloud.com
    origin_id   = aws_s3_bucket.static_site.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.static_site.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
  }

  # Add more settings as needed
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# Additional policy granting full access to DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name   = "lambda_dynamodb_access_policy"
  role   = aws_iam_role.lambda_exec.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    }
  ]
}
EOF
}

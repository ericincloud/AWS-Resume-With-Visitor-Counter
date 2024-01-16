provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
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

# S3 Bucket for Static Website
resource "aws_s3_bucket" "website" {
  bucket = "example-website-bucket" # Change to a unique bucket name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Lambda Function
resource "aws_lambda_function" "example" {
  function_name = "example_lambda_function"
  runtime       = "nodejs14.x"
  handler       = "index.handler"
  filename      = "lambda.zip" # Make sure to provide the correct zip file

  source_code_hash = filebase64("lambda.zip")

  role = aws_iam_role.lambda.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.example.name
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "example" {
  name        = "example_api"
  description = "Example API"
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id          = aws_api_gateway_rest_api.example.id
  resource_id          = aws_api_gateway_resource.example.id
  http_method          = aws_api_gateway_method.example.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  uri                  = aws_lambda_function.example.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.example]

  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "prod"
}

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda" {
  name        = "lambda_policy"
  description = "Policy for Lambda execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "dynamodb:*",
      Effect   = "Allow",
      Resource = aws_dynamodb_table.example.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = aws_iam_policy.lambda.arn
  role       = aws_iam_role.lambda.name
}




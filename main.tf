provider "aws" {
  region = "us-west-1"  # Change to your desired AWS region
}

resource "aws_s3_bucket" "StaticSite" {
  bucket = "ericincloud.com"
}
  
resource "aws_s3_bucket_public_access_block" "StaticSite" {
  bucket = "ericincloud.com"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# CloudFront

locals {
  s3_origin_id = "ericincloud.com"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = "ericincloud.com.s3.us-west-1.amazonaws.com"
    origin_id                = "ericincloud.com"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "TF"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
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
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"  # Full access to DynamoDB policy
  role       = aws_iam_role.lambda_exec.name
}




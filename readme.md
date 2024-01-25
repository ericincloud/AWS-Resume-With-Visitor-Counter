 # Welcome to my AWS Resume with Visitor Counter!

## Overview

#### This project aims to demonstrate a diverse 3 Tier Cloud Architecture utilizing AWS services. These services include S3 to host a static website, a DynamoDB table to write to and retrieve data from, API Gateway with Lambda functions to provide logic, and Route 53/CloudFront to improve performance — all packaged with Terraform and integrated with GitHub Actions to provide CI/CD capabilities. All services will be deployed in AWS Region “us-west-1”. 

##### *To improve results, please replace“ericincloud.com” to whatever domain you own”

## Setup

#### Step 1: Deploy infrastructure with Terraform

#### The following should be created/deployed: S3 bucket with the name “ericincloud.com”, a DynamoDB table named “Visitor_Count” with Partition Key “Visitor” and Sort Key “TotalVisitors”, Lambda Functions “visitor_counter” and “retrieve_visitor_count” both with the IAM role “lambda_exec_role” granting full access to DynamoDB, and a CloudFront distribution.

 <br>

#### Step  2: Moving over to API Gateway, we can now create an API to connect to the Lambda function. Create a REST API then create a POST method. Select the Lambda function named “VisitorCounter” and the region us-west-1. To deploy, click on deploy to create a new stage. After deploying, you should be able to see a URL. Copy the URL and place it in the “Visitor Counter Write” script within the index.html file.

#### Step 3: Next, head to Lambda and select the “RetrieveVisitorCount” function. Click on the “Configuration” tab > “Function URL” > “Create function URL”. Auth type: “NONE” > Additional settings > enable “Configure cross-origin resource sharing (CORS)” > Save. Copy the newly created Lambda function URL and paste it in the “Retrieve Visitor Count” script within the index.html file.

#### Step 5: Upload files “index.html”, “style.css”, and “avatarmaker.png” to the “ericincloud.com” S3 Bucket. Enable Static Site Hosting in the properties settings of the S3 Bucket. Set index.html as the default page of the site. 

#### Step 6: Now head to CloudFront and edit settings. Under “Alternate domain name (CNAME)” enter “ericincloud.com”. For “Custom SSL certificate”, select an already created SSL certificate or click on “Request certificate” to quickly create a new one. Create records in Route 53 if needed.
 
#### Step 7: Copy the “Distribution domain name” under the general tab. Then head over to Route 53. Click on the hosted zone for “ericincloud.com” and edit the A record. Select route traffic to “Alias to CloudFront distribution” and paste in the CloudFront distribution domain name. This will direct traffic to CloudFront then to the S3 bucket instead of traffic going directly to the bucket itself.

#### By now, you should be able to publicly access the website. If not, make sure the above steps are properly configured or visit the troubleshooting section at the bottom.  

#### Step 8: And done! The result is a static resume website secured with SSL/TLS with enhanced performance through CloudFront and a visitor counter that uses a REST API/Lambda URL integrated with Lambda functions to update the visitor count via a DynamoDB table!

## Troubleshooting

#### Website not showing up?  —  Try these solutions!

#### 1. Invalidate CloudFront distribution by creating an invalidation within the CloudFront distribution “Invalidation” tab. Enter “/*” under Object paths and create invalidation. This removes cached content from the CDN so that new content can be delivered to users.

#### 2. Make sure you’ve configured records in Route 53 after creating a new SSL/TLS certificate.

#### 3. Add “ericincloud.com”  under “Alternate domain name (CNAME)” within the CloudFront distribution settings.

#### 4. Use this bucket policy: 

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::ericincloud.com/*"
        }
    ]
}


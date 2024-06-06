 # AWS-Resume-With-Visitor-Counter

## Overview

#### AWS-Resume-With-Visitor-Counter is an advanced 3-tier cloud architecture that utilizes AWS services to create a static resume website with an integrated visitor counter. The architecture incorporates S3 for static website hosting, DynamoDB for data storage and retrieval, and API Gateway alongside Lambda functions for backend logic. Performance is enhanced through Route 53 and CloudFront, while Terraform and GitHub Actions facilitate continuous integration and deployment (CI/CD). All services are deployed in the AWS US-West-1 region.

![image](https://github.com/ericincloud/AWS-Resume-With-Visitor-Counter/assets/144301872/622047e4-36de-4fd3-8d94-6e6b81b57be2)

### NOTE: *Terraform file (main.tf) in repository.*

## Step 1: Terraform 
#### Deploy infrastructure with Terraform. The following should be created/deployed: S3 bucket with the name “ericincloud.com” (for me), a DynamoDB table named “Visitor_Count” with Partition Key “Visitor” and Sort Key “TotalVisitors”, Lambda Functions “visitor_counter” and “retrieve_visitor_count” both with the IAM role “lambda_exec_role” granting full access to DynamoDB, and a CloudFront distribution.

![AWSresumetf](https://github.com/ericincloud/AWS-Resume-With-Visitor-Counter/assets/144301872/aad08ed9-feb6-47f8-9c8a-0cc6a32e1700)

## Step  2: API Gateway
#### Moving over to API Gateway, we can now create an API to connect to the Lambda function. Create a REST API then create a POST method. Select the Lambda function named “VisitorCounter” and the region us-west-1. To deploy, click on deploy to create a new stage. After deploying, you should be able to see a URL. Copy the URL and place it in the “Visitor Counter Write” script within the index.html file.

![AWSresumeAPI](https://github.com/ericincloud/AWS-Resume-With-Visitor-Counter/assets/144301872/ea9a6035-65af-4f92-bec6-842031cfbdad)

## Step 3: Lambda 
#### Next, head to Lambda and select the “RetrieveVisitorCount” function. Click on the “Configuration” tab > “Function URL” > “Create function URL”. Auth type: “NONE” > Additional settings > enable “Configure cross-origin resource sharing (CORS)” > Save. Copy the newly created Lambda function URL and paste it in the “Retrieve Visitor Count” script within the index.html file.

## Step 4: S3
#### Upload files “index.html”, “style.css”, and “avatarmaker.png” to the “ericincloud.com” S3 Bucket. Enable Static Site Hosting in the properties settings of the S3 Bucket. Set index.html as the default page of the site. 

![AWSresumesS3](https://github.com/ericincloud/AWS-Resume-With-Visitor-Counter/assets/144301872/23e16b1a-bac6-4cc0-97a7-72ac62e90543)

## Step 5: CloudFront
#### Now head to CloudFront and edit settings. Under “Alternate domain name (CNAME)” enter “ericincloud.com”. For “Custom SSL certificate”, select an already created SSL certificate or click on “Request certificate” to quickly create a new one. Create records in Route 53 if needed.

![AWSresumeCF](https://github.com/ericincloud/AWS-Resume-With-Visitor-Counter/assets/144301872/7d07c5a4-4d8c-43a6-a893-411045f26752)
 
## Step 6: Route53
#### Copy the “Distribution domain name” under the general tab. Then head over to Route 53. Click on the hosted zone for “ericincloud.com” and edit the A record. Select route traffic to “Alias to CloudFront distribution” and paste in the CloudFront distribution domain name. This will direct traffic to CloudFront then to the S3 bucket instead of traffic going directly to the bucket itself.

![AWSresumeR53](https://github.com/ericincloud/AWS-Resume-With-Visitor-Counter/assets/144301872/03298837-171d-4b0e-bf6d-5baed98cdee2)

## Step 7: Finish
#### And done! By now, you should be able to publicly access the website. If not, make sure the above steps are properly configured or visit the troubleshooting section at the bottom.

#### The result is a static resume website secured with SSL/TLS with enhanced performance through CloudFront and a visitor counter that uses a REST API/Lambda URL integrated with Lambda functions to update the visitor count via a DynamoDB table.

![AWSResumeSite](https://github.com/ericincloud/AWS-Resume-With-Visitor-Counter/assets/144301872/4837aa15-869e-44dd-9079-2c47203a0b43)

## Troubleshooting

#### Website not showing up? 

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


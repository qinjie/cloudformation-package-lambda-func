# CloudFormation Package Lambda Function Demo

A demonstration project showing how to use AWS CloudFormation's `package` and `deploy` commands to create and update Lambda functions with automatic code change detection.

## Overview

This project demonstrates the complete workflow for deploying and updating an AWS Lambda function using CloudFormation. The `aws cloudformation package` command automatically handles code uploads to S3 and detects changes, making it ideal for CI/CD workflows.

## Project Structure

```
.
├── lambda_function.py              # Python Lambda function code
├── cloudformation_template.yaml    # CloudFormation template
├── deploy.sh                       # Automated deployment script
├── check-bucket-region.sh          # Utility to verify S3 bucket region
├── .gitignore                      # Git ignore file
├── Note.md                         # Detailed step-by-step guide
└── README.md                       # This file
```

## Prerequisites

- AWS CLI installed and configured
- AWS account with appropriate permissions
- An S3 bucket for storing Lambda deployment artifacts
- Python 3.11 runtime support

## Quick Start

### Option 1: Automated Deployment (Recommended)

Use the provided deployment script:

```bash
./deploy.sh your-bucket-name
```

The script will automatically:
- Zip the Lambda function
- Package the CloudFormation template
- Deploy the stack

### Option 2: Manual Deployment

### 1. Package the Lambda Function

Create a zip file of your Lambda code:

```bash
zip lambda_function.zip lambda_function.py
```

### 2. Package the CloudFormation Template

Upload the Lambda code to S3 and generate a packaged template (replace `YOUR_BUCKET_NAME` with your S3 bucket):

```bash
aws cloudformation package \
  --template-file cloudformation_template.yaml \
  --s3-bucket YOUR_BUCKET_NAME \
  --output-template-file packaged-template.yaml
```

### 3. Deploy the Stack

Deploy the Lambda function using CloudFormation:

```bash
aws cloudformation deploy \
  --template-file packaged-template.yaml \
  --stack-name hello-world-lambda \
  --capabilities CAPABILITY_IAM
```

### 4. Test the Lambda Function

After deployment, test your Lambda function:

```bash
aws lambda invoke \
  --function-name HelloWorldLambda \
  --payload '{}' \
  response.json
```

## Updating the Lambda Function

To update the Lambda function code:

1. Edit [lambda_function.py](lambda_function.py)
2. Run the deploy script again: `./deploy.sh your-bucket-name`

CloudFormation automatically detects code changes and updates the Lambda function in your stack.

**Note**: If you run the deploy script without making any code changes, you'll see the message:
```
No changes to deploy. Stack hello-world-lambda is up to date
```
This is expected behavior - CloudFormation uses content hashing to detect that nothing has changed and skips the deployment.

## How It Works

The `aws cloudformation package` command:

- Uploads local code artifacts to S3
- Generates a unique S3 key using content hash
- Replaces placeholder S3 references in the template
- Creates a new packaged template ready for deployment

This approach ensures:
- Automatic change detection based on content
- No manual S3 upload management
- Repeatable deployments
- Version tracking through content hashing

## Resources Created

The CloudFormation stack creates:

- **HelloWorldLambda** - Lambda function with Python 3.11 runtime
- **LambdaExecutionRole** - IAM role with CloudWatch Logs permissions

## Configuration

The Lambda function is configured with:
- Runtime: Python 3.11
- Timeout: 15 seconds
- Memory: 128 MB
- Handler: `lambda_function.lambda_handler`

## Deployment Script

The [deploy.sh](deploy.sh) script simplifies deployment by accepting the S3 bucket name as an argument:

```bash
./deploy.sh your-bucket-name
```

It performs three steps:
1. Zips the Lambda function code
2. Packages the CloudFormation template and uploads to S3
3. Deploys the stack

## Additional Information

For a detailed step-by-step guide with explanations, see [Note.md](Note.md).

## Clean Up

To delete all resources created by this demo:

```bash
aws cloudformation delete-stack --stack-name hello-world-lambda
```

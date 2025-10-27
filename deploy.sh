#!/bin/bash

# Simple CloudFormation Lambda Deployment Script
# Usage: ./deploy.sh <bucket-name>

set -e

# Check if bucket name provided
if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh <bucket-name> [region]"
    exit 1
fi

BUCKET_NAME=$1
REGION=${2:-$(aws configure get region)}  # Use provided region or default
TEMPLATE_FILE="cloudformation_template.yaml"
PACKAGED_TEMPLATE="packaged-template.yaml"
STACK_NAME="hello-world-lambda"

echo "Starting deployment to region: $REGION"

# Zip Lambda function
echo "Zipping Lambda function..."
zip -q lambda_function.zip lambda_function.py

# Package CloudFormation template
echo "Packaging template..."
aws cloudformation package \
    --template-file $TEMPLATE_FILE \
    --s3-bucket $BUCKET_NAME \
    --region $REGION \
    --output-template-file $PACKAGED_TEMPLATE

# Deploy stack
echo "Deploying stack..."
aws cloudformation deploy \
    --template-file $PACKAGED_TEMPLATE \
    --stack-name $STACK_NAME \
    --region $REGION \
    --capabilities CAPABILITY_IAM

echo "Deployment complete!"
echo "Stack name: $STACK_NAME"

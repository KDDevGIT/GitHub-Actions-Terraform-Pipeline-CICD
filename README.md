# GitHub Actions Terraform Pipeline CI/CD

This project demonstrates a CI/CD pipeline for Terraform using GitHub Actions. It provisions AWS resources (an example S3 bucket module) across two environments (dev and prod) with the following workflow:

## Features
- Pull Requests: run terraform fmt, validate, plan and comment plan results.
- Merges to main: run terraform apply for dev automatically, while prod requires manual approval via protected environments.
- Security: uses OIDC authentication to AWS (no static credentials) and an S3 + DynamoDB backend for remote state + locking.

## Prerequisites
- Terraform >= 1.5
- AWS CLI installed and configured
- A GitHub repository with Actions enabled

An AWS account with:
- S3 bucket (for remote backend)
- DynamoDB table (for state locking)
- IAM Role with OIDC trust 

## AWS Backend
```bash
aws s3api create-bucket --bucket tfstate-yourcompany-prod \
--create-bucket-configuration LocationConstraint=us-west-2 --region us-west-2

aws dynamodb create-table \
--table-name tf-locks \
--attribute-definitions AttributeName=LockID,AttributeType=S \
--key-schema AttributeName=LockID,KeyType=HASH \
--billing-mode PAY_PER_REQUEST \
--region us-west-1
```

## Configure GitHub OIDC -> AWS
- Create an IAM role (e.g., GitHubTerraformRole).
- Trust policy allows repo:ORG/REPO:* with provider token.actions.githubusercontent.com

Add to GitHub repository:
- Secret → AWS_ROLE_TO_ASSUME
- Variables → AWS_REGION, TF_BACKEND_BUCKET, TF_BACKEND_TABLE

## Local Development
```bash
cd infra/envs/dev
terraform init -backend-config=backend.tfvars
terraform fmt -recursive
terraform validate
terraform plan -var-file=vars.tfvars
terraform apply -var-file=vars.tfvars
```

## Using Makefile
```bash
make fmt ENV=dev
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
```

## GitHub Actions Workflows
terraform-plan.yml
- Runs on PRs or manual dispatch
- Executes fmt, init, validate, and plan
- Comments plan output on PR

terraform-apply.yml
- Runs on merge to main or manual dispatch
- Applies to dev automatically
- Applies to prod only with manual approval (protected environment)
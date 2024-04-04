# Terraform AWS Deployment
## Introduction
This repository contains Terraform scripts for deploying a scalable web application infrastructure on AWS, including an Application Load Balancer (ALB), Auto Scaling Group (ASG), security groups, and a launch template for EC2 instances. It also uses GitHub Actions for Continuous Integration and Continuous Deployment (CI/CD) processes, enabling automated updates and deployments across different branches and environments.

## Repository Structure
- terraform/ - Contains all Terraform scripts for infrastructure provisioning.
  - variables.tf - Defines input variables.
  - main.tf - Contains the main set of Terraform configuration scripts.
  - checkout.py - A Python script triggered during the CI/CD process to check the instance refresh status.
- .github/workflows/ - Contains GitHub Actions workflow definitions.
  - master-branch.yaml - Workflow for deploying changes to the production environment.
  - other-branches.yaml - Workflow for deploying changes to staging or other environments.

## Prerequisites
1. AWS Account
2. Terraform installed
3. Python3 for running scripts
4. GitHub account for setting up Actions

## Setup Instructions
1. AWS Configuration: Ensure you have the necessary AWS resources and permissions set up, including an IAM role with sufficient privileges, VPC, subnets, and an ACM certificate if HTTPS is required.

2. GitHub Secrets: Configure the following secrets in your GitHub repository to store sensitive information securely:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_DEFAULT_REGION
  - Secrets related to your infrastructure resources like INSTANCE_IP, SSH_PRIVATE_KEY, etc.

3. Terraform Initialization:
  - Navigate to the terraform/ directory.
  - Run terraform init to initialize a Terraform working directory.

4. Deployment:
  - Apply Terraform configurations using terraform apply within the terraform/ directory.
  - Confirm the changes to provision the infrastructure.

## CI/CD Workflows
1. Production Deployment (master-branch.yaml)
Triggered manually via GitHub Actions to update the AMI in the ASG launch template for production environments. It includes steps for checking out the code, preparing the instance, importing existing resources into the Terraform state, and applying Terraform changes.

2. Staging/Other Branches Deployment (other-branches.yaml)
Designed for staging or other environments, this workflow is also triggered manually. It updates the server's codebase based on the branch specified and can include steps for restarting or configuring the server as needed.

## Usage
To deploy or update your infrastructure:
  1. For Production: Run the Update AMI in ASG Launch Template Production workflow from the Actions tab in GitHub.
  For Staging/Other Environments: Run the CICD for staging server workflow, selecting the branch you wish to deploy.
  Contributing
  2. Contributions to this project are welcome. Please ensure you follow the best practices for Terraform and AWS resource management and update the README accordingly with any significant changes or additions.

## License
Specify your license or state that the project is unlicensed and free for use.


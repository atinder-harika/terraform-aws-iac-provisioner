# Setup Guide

Complete setup instructions for deploying the Terraform AWS Infrastructure Provisioner.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [AWS Configuration](#aws-configuration)
3. [Local Development Setup](#local-development-setup)
4. [Terraform Configuration](#terraform-configuration)
5. [Deployment](#deployment)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Tool | Minimum Version | Installation |
|------|----------------|--------------|
| Terraform | v1.5+ | [Download](https://www.terraform.io/downloads.html) |
| AWS CLI | v2.0+ | [Download](https://aws.amazon.com/cli/) |
| Docker | v20.0+ | [Download](https://docs.docker.com/get-docker/) |
| Git | v2.0+ | [Download](https://git-scm.com/downloads) |

### AWS Account Requirements

- Active AWS account with billing enabled
- IAM user with programmatic access
- Minimum IAM permissions:
  - EC2 Full Access
  - VPC Full Access
  - S3 Full Access
  - IAM permissions for resource tagging

---

## AWS Configuration

### Step 1: Create IAM User

1. Log in to AWS Console
2. Navigate to **IAM** → **Users** → **Add users**
3. User name: `terraform-deployer`
4. Access type: **Programmatic access** ✅
5. Attach policies:
   - `AmazonEC2FullAccess`
   - `AmazonS3FullAccess`
   - `AmazonVPCFullAccess`
6. Save the **Access Key ID** and **Secret Access Key**

### Step 2: Configure AWS CLI

```bash
aws configure

# Enter when prompted:
AWS Access Key ID: <YOUR_ACCESS_KEY>
AWS Secret Access Key: <YOUR_SECRET_KEY>
Default region name: us-east-1
Default output format: json
```

### Step 3: Verify AWS Configuration

```bash
# Test AWS credentials
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/terraform-deployer"
# }
```

---

## Local Development Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/terraform-aws-iac-provisioner.git
cd terraform-aws-iac-provisioner
```

### Step 2: Verify Terraform Installation

```bash
terraform version

# Expected output:
# Terraform v1.5.0 (or higher)
```

---

## Terraform Configuration

### Step 1: Configure Backend (Optional but Recommended)

Edit `terraform/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

**Note:** For first-time setup, you can comment out the backend block and use local state.

### Step 2: Configure Environment Variables

Navigate to your target environment:

```bash
cd terraform/environments/dev
```

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
environment = "dev"

vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]

project_name = "my-app"
```

---

## Deployment

### Step 1: Initialize Terraform

```bash
cd terraform/environments/dev
terraform init

# Expected output:
# Terraform has been successfully initialized!
```

### Step 2: Validate Configuration

```bash
terraform validate

# Expected output:
# Success! The configuration is valid.
```

### Step 3: Format Code

```bash
terraform fmt -recursive
```

### Step 4: Plan Deployment

```bash
terraform plan

# Review the output:
# - Resources to be created
# - Estimated costs
# - Potential issues
```

### Step 5: Apply Configuration

```bash
terraform apply

# Type 'yes' when prompted to confirm
```

**Deployment Time:** Approximately 3-5 minutes for complete infrastructure provisioning.

### Step 6: Capture Outputs

After successful deployment:

```bash
terraform output

# Expected output:
# vpc_id = "vpc-0123456789abcdef0"
# public_subnet_ids = ["subnet-abc123", "subnet-def456"]
# private_subnet_ids = ["subnet-ghi789", "subnet-jkl012"]
```

---

## Verification

### Verify VPC Creation

```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=dev-vpc"
```

### Verify Subnets

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<YOUR_VPC_ID>"
```

### Verify Security Groups

```bash
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<YOUR_VPC_ID>"
```

### Verify S3 Buckets

```bash
aws s3 ls | grep dev
```

---

## Troubleshooting

### Issue: AWS Credentials Not Found

**Error:**
```
Error: No valid credential sources found for AWS Provider
```

**Solution:**
```bash
# Reconfigure AWS CLI
aws configure

# Or export credentials as environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

---

### Issue: Resource Already Exists

**Error:**
```
Error: creating VPC: VpcLimitExceeded
```

**Solution:**
- Check your AWS VPC limit (default is 5 per region)
- Delete unused VPCs or request limit increase
- Use a different AWS region

---

### Issue: Terraform State Lock

**Error:**
```
Error acquiring the state lock
```

**Solution:**
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>

# Or delete DynamoDB lock entry manually
```

---

### Issue: Subnet CIDR Overlap

**Error:**
```
Error: creating Subnet: InvalidSubnet.Conflict
```

**Solution:**
- Ensure subnet CIDRs don't overlap
- Verify VPC CIDR can accommodate all subnets
- Check for existing subnets in the VPC

---

### Issue: Insufficient IAM Permissions

**Error:**
```
Error: creating Security Group: UnauthorizedOperation
```

**Solution:**
- Verify IAM user has required permissions
- Check IAM policy attachments
- Review CloudTrail logs for specific denied actions

---

## Cleanup

To destroy all provisioned infrastructure:

```bash
cd terraform/environments/dev
terraform destroy

# Type 'yes' when prompted to confirm
```

**Warning:** This action is irreversible. All resources will be permanently deleted.

---

## Next Steps

- Review [LEARNING_ROADMAP.md](LEARNING_ROADMAP.md) for advanced Terraform patterns
- Explore multi-environment deployments (staging, production)
- Implement CI/CD pipelines for automated deployments
- Add RDS databases and ElastiCache clusters
- Configure VPN or Direct Connect for hybrid cloud setups

---

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform Module Development](https://www.terraform.io/docs/language/modules/develop/index.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Need help?** Open an issue on [GitHub](https://github.com/yourusername/terraform-aws-iac-provisioner/issues)

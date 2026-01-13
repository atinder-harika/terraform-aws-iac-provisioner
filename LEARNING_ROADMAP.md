# Learning Roadmap: Terraform & AWS Infrastructure as Code

This document provides a structured learning path to master Infrastructure as Code (IaC) with Terraform on AWS. Follow this roadmap to build production-ready cloud infrastructure skills progressively.

---

## Table of Contents

1. [Phase 1: Foundation](#phase-1-foundation)
2. [Phase 2: Core Terraform](#phase-2-core-terraform)
3. [Phase 3: AWS Integration](#phase-3-aws-integration)
4. [Phase 4: Advanced Patterns](#phase-4-advanced-patterns)
5. [Phase 5: Production Practices](#phase-5-production-practices)
6. [Learning Resources](#learning-resources)

---

## Phase 1: Foundation

### AWS Basics Revision

**Goal:** Understand core AWS services and cloud concepts

#### Key Services to Master

**1. EC2 (Elastic Compute Cloud)**
- Instance types and families (t2, t3, m5, c5)
- AMI (Amazon Machine Images) selection
- Security groups vs NACLs
- Key pairs and SSH access
- User data scripts for initialization
- Instance metadata service

**Learning Exercise:**
```bash
# Launch a simple EC2 instance manually
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --key-name my-key-pair \
  --security-group-ids sg-903004f8 \
  --subnet-id subnet-6e7f829e

# Practice: Launch instances in different AZs and test connectivity
```

**2. VPC (Virtual Private Cloud)**
- CIDR block planning and subnetting
- Public vs private subnets
- Internet Gateway (IGW) for public internet access
- NAT Gateway for private subnet outbound traffic
- Route tables and routing rules
- Network ACLs (NACLs) for subnet-level security

**Learning Exercise:**
```
Design a VPC architecture for a 3-tier application:
- VPC CIDR: 10.0.0.0/16
- Public subnets: 10.0.1.0/24, 10.0.2.0/24 (web tier)
- Private subnets: 10.0.11.0/24, 10.0.12.0/24 (app tier)
- Database subnets: 10.0.21.0/24, 10.0.22.0/24 (data tier)

Practice: Draw this architecture and identify routing requirements
```

**3. S3 (Simple Storage Service)**
- Bucket naming conventions and restrictions
- Object versioning for data protection
- Lifecycle policies for cost optimization
- Encryption at rest (SSE-S3, SSE-KMS)
- Bucket policies vs IAM policies
- Static website hosting

**Learning Exercise:**
```bash
# Create a versioned bucket with encryption
aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Practice: Enable server-side encryption and lifecycle rules
```

**4. IAM (Identity and Access Management)**
- Users, groups, and roles
- Policy structure (Effect, Action, Resource, Condition)
- Principle of least privilege
- Service roles for EC2, Lambda, etc.
- Cross-account access patterns
- MFA enforcement

**Learning Exercise:**
```json
// Create a policy that allows Terraform to provision resources
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "vpc:*"
      ],
      "Resource": "*"
    }
  ]
}

// Practice: Refine this policy to follow least privilege
```

**5. Security Groups**
- Stateful firewall rules
- Inbound vs outbound rules
- Source/destination options (CIDR, security group, prefix list)
- Common port numbers (22-SSH, 80-HTTP, 443-HTTPS, 3306-MySQL)
- Security group chaining patterns

**Learning Exercise:**
```
Design security groups for:
1. Web tier SG: Allow 80/443 from 0.0.0.0/0, allow SSH from your IP
2. App tier SG: Allow custom ports from Web tier SG only
3. DB tier SG: Allow 3306 from App tier SG only

Practice: Implement these in AWS Console, test connectivity
```

#### AWS CLI Commands Reference

```bash
# Configure AWS CLI
aws configure

# List available regions
aws ec2 describe-regions --output table

# Describe VPCs
aws ec2 describe-vpcs

# List EC2 instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress]' --output table

# List S3 buckets
aws s3 ls

# Get current IAM user
aws sts get-caller-identity
```

---

## Phase 2: Core Terraform

### Terraform Fundamentals

**Goal:** Master Terraform syntax, workflow, and core concepts

#### 1. Terraform Language (HCL)

**Resource Blocks:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}
```

**Variables:**
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Usage: var.instance_type
```

**Outputs:**
```hcl
output "instance_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.web.public_ip
}
```

**Data Sources:**
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
```

**Locals:**
```hcl
locals {
  common_tags = {
    Project     = "MyApp"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Usage: tags = local.common_tags
```

#### 2. Terraform Workflow

```bash
# Initialize working directory (downloads providers)
terraform init

# Validate configuration syntax
terraform validate

# Format code to canonical style
terraform fmt -recursive

# Show execution plan
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources in state
terraform state list

# Destroy all resources
terraform destroy
```

#### 3. State Management

**Local State:**
```hcl
# Default: terraform.tfstate in current directory
# Not recommended for team environments
```

**Remote State (S3 Backend):**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**State Locking:** Prevents concurrent modifications using DynamoDB

#### 4. Modules

**Module Structure:**
```
modules/
└── networking/
    ├── main.tf       # Resource definitions
    ├── variables.tf  # Input variables
    └── outputs.tf    # Output values
```

**Using Modules:**
```hcl
module "vpc" {
  source = "./modules/networking"
  
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  environment         = "dev"
}

# Access module outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}
```

#### Learning Exercises

**Exercise 1: Create Your First Resource**
```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name-12345"
}
```

**Exercise 2: Add Variables**
```hcl
# variables.tf
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# main.tf
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  
  tags = {
    Environment = var.environment
  }
}
```

**Exercise 3: Create a Module**
```hcl
# modules/s3_bucket/main.tf
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# modules/s3_bucket/variables.tf
variable "bucket_name" {
  type = string
}

# modules/s3_bucket/outputs.tf
output "bucket_id" {
  value = aws_s3_bucket.this.id
}

# Root main.tf
module "my_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "my-app-bucket"
}
```

---

## Phase 3: AWS Integration

### Building Production VPC Infrastructure

**Goal:** Create multi-tier VPC architecture with Terraform

#### 1. VPC Module Deep Dive

**Complete VPC Configuration:**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
    Tier = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

#### 2. Security Groups Pattern

**Layered Security Approach:**
```hcl
# Web tier - public facing
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web tier"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App tier - only accessible from web tier
resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for app tier"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

#### Learning Exercises

**Exercise 1: Deploy Complete VPC**
- Create VPC with 2 public and 2 private subnets across 2 AZs
- Configure Internet Gateway and routing
- Test connectivity from public subnet to internet
- Verify private subnets cannot reach internet directly

**Exercise 2: Add NAT Gateway**
```hcl
resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_nat" {
  count                  = length(var.private_subnet_cidrs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}
```

**Exercise 3: Multi-Environment Deployment**
- Create separate environments: dev, staging, prod
- Use workspaces or separate state files
- Parameterize everything (CIDR blocks, instance types, counts)
- Apply consistent tagging strategy

---

## Phase 4: Advanced Patterns

### Future Implementation Topics

#### 1. RDS Database Integration
- Multi-AZ RDS deployment
- Database subnet groups
- Parameter groups and option groups
- Automated backups and snapshots
- Read replicas for scaling

#### 2. Application Load Balancer
- ALB target groups
- Health checks configuration
- SSL/TLS certificate management (ACM)
- Path-based and host-based routing
- Connection draining

#### 3. Auto Scaling
- Launch templates
- Auto Scaling groups
- Scaling policies (target tracking, step scaling)
- Lifecycle hooks
- Integration with ALB

#### 4. Secrets Management
- AWS Secrets Manager integration
- Parameter Store usage
- Rotating credentials
- Encryption with KMS

#### 5. Monitoring & Logging
- CloudWatch Logs groups
- CloudWatch Alarms
- VPC Flow Logs
- CloudTrail for audit logging

---

## Phase 5: Production Practices

### Future Advanced Topics

#### 1. Terratest - Infrastructure Testing
```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCCreation(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../terraform/environments/dev",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

#### 2. Multi-Region Deployment
- Region-specific modules
- Cross-region replication
- Latency-based routing
- Disaster recovery strategies

#### 3. Terraform Cloud / Enterprise
- Remote execution
- Sentinel policy as code
- Cost estimation
- Private module registry

#### 4. GitOps Workflow
- PR-based infrastructure changes
- Automated plan on PR
- Manual approval gates
- Automated apply on merge

#### 5. Cost Optimization
- Resource tagging for cost allocation
- Instance right-sizing
- Spot instances for non-critical workloads
- S3 lifecycle policies
- Reserved instance planning

---

## Learning Resources

### Official Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Books
- "Terraform: Up & Running" by Yevgeniy Brikman
- "AWS Certified Solutions Architect Study Guide"

### Hands-On Labs
- [AWS Free Tier](https://aws.amazon.com/free/)
- [HashiCorp Learn Terraform](https://learn.hashicorp.com/terraform)
- [AWS Workshops](https://workshops.aws/)

### Best Practices
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

---

## Progress Tracking

Use this checklist to track your learning progress:

- [ ] **Phase 1:** Understand AWS core services (VPC, EC2, S3, IAM)
- [ ] **Phase 1:** Practice AWS CLI commands
- [ ] **Phase 2:** Complete first Terraform resource deployment
- [ ] **Phase 2:** Create reusable Terraform module
- [ ] **Phase 2:** Implement remote state with S3 backend
- [ ] **Phase 3:** Deploy multi-tier VPC architecture
- [ ] **Phase 3:** Implement security group layering
- [ ] **Phase 3:** Configure NAT Gateway for private subnets
- [ ] **Phase 4:** Add RDS database to architecture
- [ ] **Phase 4:** Implement Application Load Balancer
- [ ] **Phase 4:** Configure Auto Scaling
- [ ] **Phase 5:** Write Terratest tests
- [ ] **Phase 5:** Implement multi-region deployment
- [ ] **Phase 5:** Set up CI/CD pipeline for IaC

---

**Next Steps:** Start with Phase 1 AWS basics revision. Take notes on key concepts and practice AWS CLI commands. Once comfortable, move to Phase 2 Terraform fundamentals.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "../../modules/networking"

  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "compute" {
  source = "../../modules/compute"

  vpc_id              = module.networking.vpc_id
  environment         = var.environment
  allowed_cidr_blocks = ["0.0.0.0/0"]
}

module "storage" {
  source = "../../modules/storage"

  bucket_prefix     = var.project_name
  environment       = var.environment
  enable_versioning = true
}
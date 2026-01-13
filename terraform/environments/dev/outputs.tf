output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}

output "web_security_group_id" {
  description = "ID of web security group"
  value       = module.compute.web_security_group_id
}

output "app_security_group_id" {
  description = "ID of app security group"
  value       = module.compute.app_security_group_id
}

output "storage_bucket_id" {
  description = "ID of S3 storage bucket"
  value       = module.storage.bucket_id
}

output "storage_bucket_arn" {
  description = "ARN of S3 storage bucket"
  value       = module.storage.bucket_arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket created for storage."
  value       = aws_s3_bucket.my_bucket.bucket
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.my_db.endpoint
}

output "rds_instance_id" {
  description = "The ID of the RDS instance."
  value       = aws_db_instance.my_db.id
}
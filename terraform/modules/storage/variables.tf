variable "bucket_name" {
  description = "The name of the S3 bucket for storage."
  type        = string
}

variable "region" {
  description = "The AWS region where the storage resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "versioning" {
  description = "Enable versioning for the S3 bucket."
  type        = bool
  default     = false
}

variable "lifecycle_rule" {
  description = "Lifecycle rules for the S3 bucket."
  type        = list(object({
    id      = string
    enabled = bool
    prefix  = string
    expiration {
      days = number
    }
  }))
  default = []
}
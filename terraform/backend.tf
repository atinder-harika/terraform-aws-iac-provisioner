terraform {
  backend "s3" {
    bucket         = "your-unique-bucket-name"
    key            = "terraform/state"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
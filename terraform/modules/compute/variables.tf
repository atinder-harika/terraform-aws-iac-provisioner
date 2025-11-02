variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
}

variable "desired_capacity" {
  description = "The desired number of instances in the auto-scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of instances in the auto-scaling group"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "The minimum number of instances in the auto-scaling group"
  type        = number
  default     = 1
}
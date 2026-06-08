variable "project" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "create_tf_backend_bucket" {
  description = "Create S3 bucket and DynamoDB table for Terraform backend (run once manually)"
  type        = bool
  default     = false
}

variable "tf_backend_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "webapp-tf-state-demo"
}

variable "tf_locks_table_name" {
  description = "DynamoDB table name for Terraform state locks"
  type        = string
  default     = "webapp-tf-locks"
}

variable "project" {
  type = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance. Use an Amazon Linux 2 or RHEL AMI for your region (e.g. ami-0c55b159cbfafe1f0 for us-east-1)"
  type        = string
  default     = "ami-00e801948462f718a"
}

variable "instance_type" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "db_host" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "s3_bucket_name" {
  type = string
}

variable "key_name" {
  description = "SSH key pair name (optional)"
  type        = string
  default     = ""
}

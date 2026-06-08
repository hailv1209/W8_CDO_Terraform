output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "web_server_public_ip" {
  description = "Public IP of the web server EC2 instance"
  value       = module.ec2.web_instance_public_ip
}

output "web_server_private_ip" {
  description = "Private IP of the web server EC2 instance"
  value       = module.ec2.web_instance_private_ip
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.rds_database_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for static assets"
  value       = module.s3.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.s3_bucket_arn
}

output "web_security_group_id" {
  description = "Security group ID for the web server"
  value       = module.security_groups.web_security_group_id
}

output "rds_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = module.security_groups.rds_security_group_id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.web_instance_id
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.rds_instance_id
}

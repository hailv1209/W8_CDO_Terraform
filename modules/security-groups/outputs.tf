output "web_security_group_id" {
  description = "Security group ID for the web server"
  value       = aws_security_group.web.id
}

output "rds_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = aws_security_group.rds.id
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC Endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

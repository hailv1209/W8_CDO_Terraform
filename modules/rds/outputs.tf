output "rds_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.mysql.id
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mysql.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.mysql.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.mysql.db_name
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.mysql.arn
}

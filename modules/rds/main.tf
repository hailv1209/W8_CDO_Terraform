resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.project}-mysql"

  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_encrypted    = true
  storage_type         = "gp3"

  db_name  = replace(var.db_name, "-", "_")
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  skip_final_snapshot = true
  deletion_protection  = false

  performance_insights_enabled = false

  tags = {
    Name = "${var.project}-rds-mysql"
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project}-db-password"

  recovery_window_in_days = 7

  tags = {
    Name    = "${var.project}-db-password"
    Project = var.project
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

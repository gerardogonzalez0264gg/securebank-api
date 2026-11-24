resource "aws_db_subnet_group" "db" {
  name       = "securebank-db"
  subnet_ids = aws_subnet.subnet_priv[*].id
}

# Query logging de PostgreSQL (trazabilidad de sentencias y consultas lentas).
resource "aws_db_parameter_group" "postgres" {
  name   = "securebank-postgres16"
  family = "postgres16"

  # Cifrado en tránsito: rechaza conexiones sin TLS.
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }
}

# rds_postgres: privada, cifrada, con logs y clave gestionada por Secrets Manager
# (no hay contraseña en el código ni en variables).
resource "aws_db_instance" "rds_postgres" {
  identifier        = "securebank-postgres"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.db_instance_class
  allocated_storage = 20

  db_name                     = "securebank"
  username                    = var.db_username
  manage_master_user_password = true

  parameter_group_name   = aws_db_parameter_group.postgres.name
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  publicly_accessible    = false

  storage_encrypted = true
  kms_key_id        = aws_kms_key.kms_key.arn

  multi_az                            = true
  backup_retention_period             = 7
  deletion_protection                 = true
  auto_minor_version_upgrade          = true
  copy_tags_to_snapshot               = true
  iam_database_authentication_enabled = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "securebank-postgres-final"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.kms_key.arn
}

# dynamodb_txn: registro de transacciones, cifrado con KMS y con recuperación a un punto en el tiempo.
resource "aws_dynamodb_table" "dynamodb_txn" {
  name         = "securebank-transactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "txn_id"

  attribute {
    name = "txn_id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.kms_key.arn
  }

  point_in_time_recovery {
    enabled = true
  }
}

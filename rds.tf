###############################################################################
# soc2-workshop-db
#
# PostgreSQL 15.7 on db.t3.micro, in the default VPC's default DB subnet group
# and the default.postgres15 parameter group. Not managed by this config are
# the subnet group and parameter group themselves, which are AWS-provided
# defaults and are referenced by name.
###############################################################################

resource "aws_db_instance" "workshop" {
  identifier     = "${var.name_prefix}-db"
  engine         = "postgres"
  engine_version = "15.7"
  instance_class = "db.t3.micro"

  db_name  = "appdb"
  username = "appadmin"
  password = var.db_password

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = false

  availability_zone      = "us-east-1d"
  multi_az               = false
  publicly_accessible    = true
  db_subnet_group_name   = "default"
  vpc_security_group_ids = [aws_security_group.app.id]

  parameter_group_name = "default.postgres15"
  option_group_name    = "default:postgres-15"
  ca_cert_identifier   = "rds-ca-rsa2048-g1"

  backup_retention_period = 0
  copy_tags_to_snapshot   = false
  deletion_protection     = false
  maintenance_window      = "wed:04:38-wed:05:08"

  # The live instance reports a preferred backup window of 08:51-09:21, but RDS
  # rejects setting one while backup_retention_period is 0, so it is recorded
  # here rather than declared:
  #   backup_window = "08:51-09:21"

  auto_minor_version_upgrade          = true
  iam_database_authentication_enabled = false
  monitoring_interval                 = 0
  performance_insights_enabled        = false
  engine_lifecycle_support            = "open-source-rds-extended-support"

  # Destroy-time behaviour only; not an attribute of the running instance.
  skip_final_snapshot = true
}

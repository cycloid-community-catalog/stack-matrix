#
# RDS
#

resource "aws_security_group" "postgresql_database" {
  count       = var.create_rds ? 1 : 0
  name        = "${var.project}-${var.env}-postgresql"
  description = "Allow access to the PostgreSQL database"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [aws_security_group.server.id]
  }

  tags = merge(local.merged_tags, {
    Name = "${var.project}-${var.env}-postgresql"
    role = "database"
  })
}

resource "aws_db_instance" "postgresql_database" {
  count             = var.create_rds ? 1 : 0
  identifier        = replace("${var.project}-${var.env}-postgresql", var.nameregex, "")
  allocated_storage = var.rds_disk_size
  storage_type      = var.rds_storage_type
  engine            = "postgres"
  engine_version    = var.rds_engine_version
  instance_class    = var.rds_type
  name              = var.rds_database
  username          = var.rds_username
  password          = var.rds_password

  multi_az                  = var.rds_multiaz
  apply_immediately         = true
  maintenance_window        = "tue:06:00-tue:07:00"
  backup_window             = "02:00-04:00"
  backup_retention_period   = var.rds_backup_retention
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = replace("${var.project}-${var.env}-postgresql", var.nameregex, "")
  skip_final_snapshot       = var.rds_skip_final_snapshot

  parameter_group_name = var.rds_parameters
  db_subnet_group_name = var.rds_subnet_group != "" ? var.rds_subnet_group : aws_db_subnet_group.postgresql_subnet[0].id

  vpc_security_group_ids = compact([var.rds_extra_sg_allow, aws_security_group.postgresql_database[0].id])

  tags = merge(local.merged_tags, {
    Name = "${var.customer}-${var.project}-rds-${var.env}"
    type = "master"
    role = "database"
  })

  depends_on = [
    aws_security_group.postgresql_database
  ]
}

resource "aws_db_subnet_group" "postgresql_subnet" {
  name        = "${var.project}-${var.env}-${var.vpc_id}-postgresql"
  count       = var.rds_subnet_group == "" && var.create_rds ? 1 : 0
  description = "${var.project}-${var.env}-${var.vpc_id}-subnet-postgresql"
  subnet_ids  = var.private_subnets_ids
}

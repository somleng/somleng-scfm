locals {
  database_port = 5432
  identifier = "scfmv2"
}

resource "aws_security_group" "db" {
  name   = var.app_identifier
  vpc_id = var.vpc_id

  ingress {
    from_port = local.database_port
    to_port   = local.database_port
    protocol  = "TCP"
    self      = true
  }

  tags = {
    Name = "aurora-${local.identifier}"
  }
}

resource "aws_ssm_parameter" "db_master_password" {
  name  = "${var.app_identifier}.db_master_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_db_subnet_group" "db" {
  name        = local.identifier
  description = "For Aurora cluster ${local.identifier}"
  subnet_ids  = var.database_subnets

  tags = {
    Name = "aurora-${local.identifier}"
  }
}

resource "aws_rds_cluster" "db" {
  cluster_identifier = local.identifier
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "13.6"
  master_username    = var.db_username
  master_password    = aws_ssm_parameter.db_master_password.value
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot = true
  storage_encrypted = true

  serverlessv2_scaling_configuration {
    max_capacity = 6.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "db" {
  identifier = local.identifier
  cluster_identifier = aws_rds_cluster.db.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db.engine
  engine_version     = aws_rds_cluster.db.engine_version
}

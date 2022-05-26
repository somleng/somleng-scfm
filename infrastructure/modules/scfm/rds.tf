locals {
  database_port = 5432
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
}

resource "aws_db_subnet_group" "db_old" {
  name        = "${var.app_identifier}-db"
  description = "For Aurora cluster somleng SCFM"
  subnet_ids  = var.database_subnets

  tags = {
    Name = "aurora-${var.app_identifier}"
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

module "db_old" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name = var.app_identifier
  security_group_description = "Managed by Terraform"
  database_name = replace(var.app_identifier, "-", "_")

  engine            = "aurora-postgresql"
  engine_mode       = "serverless"
  engine_version    = null
  vpc_id = var.vpc_id
  create_db_subnet_group = false
  db_subnet_group_name = aws_db_subnet_group.db_old.name
  allowed_security_groups = [aws_security_group.db.id]
  allowed_cidr_blocks = [var.vpc_cidr_block]
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  storage_encrypted           = true
  monitoring_interval = 60

  master_username = var.db_username
  master_password = aws_ssm_parameter.db_master_password.value
  create_random_password = false
  port     = local.database_port

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 64
    seconds_until_auto_pause = 600
    timeout_action           = "ForceApplyCapacityChange"
  }
}

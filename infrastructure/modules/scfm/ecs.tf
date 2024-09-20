resource "aws_ecs_cluster" "this" {
  name = var.app_identifier

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# Capacity Provider
resource "aws_ecs_capacity_provider" "this" {
  name = var.app_identifier

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.container_instances.autoscaling_group.arn
    managed_termination_protection = "ENABLED"
    managed_draining               = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [
    aws_ecs_capacity_provider.this.name,
    "FARGATE"
  ]
}

data "template_file" "webserver_container_definitions" {
  template = file("${path.module}/templates/webserver_container_definitions.json.tpl")

  vars = {
    name                             = var.app_identifier
    app_port                         = var.app_port
    app_image                        = var.app_image
    nginx_image                      = var.nginx_image
    webserver_container_name         = var.webserver_container_name
    webserver_container_port         = var.webserver_container_port
    region                           = var.aws_region
    rails_master_key_arn             = aws_ssm_parameter.rails_master_key.arn
    aws_sqs_high_priority_queue_name = aws_sqs_queue.high_priority.name
    aws_sqs_default_queue_name       = aws_sqs_queue.default.name
    aws_sqs_low_priority_queue_name  = aws_sqs_queue.low_priority.name
    aws_sqs_scheduler_queue_name     = aws_sqs_queue.scheduler.name
    nginx_logs_group                 = aws_cloudwatch_log_group.nginx.name
    app_logs_group                   = aws_cloudwatch_log_group.app.name
    logs_group_region                = var.aws_region
    app_environment                  = var.app_environment
    rails_master_key_parameter_arn   = aws_ssm_parameter.rails_master_key.arn
    database_password_parameter_arn  = aws_ssm_parameter.db_master_password.arn
    database_name                    = var.db_name
    database_username                = aws_rds_cluster.db.master_username
    database_host                    = aws_rds_cluster.db.endpoint
    database_port                    = aws_rds_cluster.db.port
    db_pool                          = var.db_pool
    uploads_bucket                   = aws_s3_bucket.uploads.id
    audio_bucket                     = aws_s3_bucket.audio.id
  }
}

data "template_file" "worker_container_definitions" {
  template = file("${path.module}/templates/worker_container_definitions.json.tpl")

  vars = {
    name                             = var.app_identifier
    app_image                        = var.app_image
    rails_master_key_arn             = aws_ssm_parameter.rails_master_key.arn
    region                           = var.aws_region
    aws_sqs_high_priority_queue_name = aws_sqs_queue.high_priority.name
    aws_sqs_default_queue_name       = aws_sqs_queue.default.name
    aws_sqs_low_priority_queue_name  = aws_sqs_queue.low_priority.name
    aws_sqs_scheduler_queue_name     = aws_sqs_queue.scheduler.name
    worker_logs_group                = aws_cloudwatch_log_group.worker.name
    logs_group_region                = var.aws_region
    app_environment                  = var.app_environment
    rails_master_key_parameter_arn   = aws_ssm_parameter.rails_master_key.arn
    database_password_parameter_arn  = aws_ssm_parameter.db_master_password.arn
    database_name                    = var.db_name
    database_username                = aws_rds_cluster.db.master_username
    database_host                    = aws_rds_cluster.db.endpoint
    database_port                    = aws_rds_cluster.db.port
    db_pool                          = var.db_pool
    uploads_bucket                   = aws_s3_bucket.uploads.id
    audio_bucket                     = aws_s3_bucket.audio.id
  }
}

resource "aws_ecs_task_definition" "webserver" {
  family                   = "${var.app_identifier}-webserver"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions    = data.template_file.webserver_container_definitions.rendered
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = module.container_instances.ec2_instance_type.memory_size - 512
}

resource "aws_ecs_service" "webserver" {
  name            = aws_ecs_task_definition.webserver.family
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.webserver.arn
  desired_count   = var.webserver_min_tasks

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.webserver.id,
      aws_security_group.db.id
    ]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.webserver.arn
    container_name   = "nginx"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.internal_webserver.arn
    container_name   = "nginx"
    container_port   = 80
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_identifier}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions    = data.template_file.worker_container_definitions.rendered
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = module.container_instances.ec2_instance_type.memory_size - 512
}

resource "aws_ecs_task_definition" "worker_fargate" {
  family                   = "${var.app_identifier}-worker-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.worker_container_definitions.rendered
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = 1024
  cpu                      = 512

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "worker" {
  name            = aws_ecs_task_definition.worker.family
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_min_tasks

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.worker.id,
      aws_security_group.db.id
    ]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  placement_constraints {
    type = "distinctInstance"
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

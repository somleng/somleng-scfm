module "scfm" {
  source = "../modules/scfm"

  ecs_cluster = data.terraform_remote_state.core.outputs.ecs_cluster
  codedeploy_role = data.terraform_remote_state.core_infrastructure.outputs.codedeploy_role
  app_identifier = "scfm"
  app_environment = "production"
  app_image = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  memory = 512
  cpu = 256
  aws_region = var.aws_region
  load_balancer_ssl_certificate_arn = data.terraform_remote_state.core_infrastructure.outputs.acm_certificate.arn
  load_balancer_subnets = data.terraform_remote_state.core_infrastructure.outputs.vpc.public_subnets
  container_instance_subnets = data.terraform_remote_state.core_infrastructure.outputs.vpc.private_subnets
  vpc_id = data.terraform_remote_state.core_infrastructure.outputs.vpc.vpc_id
  logs_bucket = data.terraform_remote_state.core_infrastructure.outputs.logs_bucket.id
  uploads_bucket = "uploads.somleng.org"
  audio_bucket = "audio.somleng.org"

  db_username = data.terraform_remote_state.core_infrastructure.outputs.db.this_rds_cluster_master_username
  db_password_parameter_arn = data.terraform_remote_state.core_infrastructure.outputs.db_master_password_parameter.arn
  db_host = data.terraform_remote_state.core_infrastructure.outputs.db.this_rds_cluster_endpoint
  db_port = data.terraform_remote_state.core_infrastructure.outputs.db.this_rds_cluster_port
  db_security_group = data.terraform_remote_state.core_infrastructure.outputs.db_security_group.id
  ecs_worker_autoscale_min_instances = 0
}
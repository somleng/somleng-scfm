module "scfm" {
  source = "../modules/scfm"

  ecs_cluster = data.terraform_remote_state.core_infrastructure.outputs.ecs_cluster
  codedeploy_role = data.terraform_remote_state.core_infrastructure.outputs.codedeploy_role
  app_identifier = "scfm"
  app_environment = "production"
  app_image = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  memory = 1024
  cpu = 512
  aws_region = var.aws_region
  load_balancer_arn = data.terraform_remote_state.core_infrastructure.outputs.application_load_balancer.arn
  listener_arn = data.terraform_remote_state.core_infrastructure.outputs.https_listener.arn
  container_instance_subnets = data.terraform_remote_state.core_infrastructure.outputs.vpc.private_subnets
  vpc_id = data.terraform_remote_state.core_infrastructure.outputs.vpc.vpc_id
  logs_bucket = data.terraform_remote_state.core_infrastructure.outputs.logs_bucket.id
  uploads_bucket = "uploads.somleng.org"
  audio_bucket = "audio.somleng.org"

  vpc_cidr_block = data.terraform_remote_state.core_infrastructure.outputs.vpc.vpc_cidr_block
  database_subnets = data.terraform_remote_state.core_infrastructure.outputs.vpc.database_subnets

  ecs_worker_autoscale_min_instances = 1
  ecs_worker_autoscale_max_instances = 4
}

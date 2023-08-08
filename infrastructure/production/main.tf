module "scfm" {
  source = "../modules/scfm"

  app_identifier = "scfm"
  subdomain = "scfm"
  cdn_subdomain = "cdn-scfm"
  app_environment = "production"
  app_image = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  memory = 1024
  cpu = 512
  aws_region = var.aws_region
  load_balancer = data.terraform_remote_state.core_infrastructure.outputs.application_load_balancer
  listener_arn = data.terraform_remote_state.core_infrastructure.outputs.https_listener.arn
  vpc = data.terraform_remote_state.core_infrastructure.outputs.vpc
  route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  cdn_certificate = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  logs_bucket = data.terraform_remote_state.core_infrastructure.outputs.logs_bucket.id
  uploads_bucket = "uploads.somleng.org"
  audio_bucket = "audio.somleng.org"
  db_name = "scfm"
}

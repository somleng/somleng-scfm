module "scfm" {
  source = "../modules/scfm"

  app_identifier         = "scfm"
  subdomain              = "scfm"
  cdn_subdomain          = "cdn-scfm"
  audio_subdomain        = "audio"
  app_environment        = "production"
  app_image              = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image            = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  aws_region             = var.aws_region
  load_balancer          = data.terraform_remote_state.core_infrastructure.outputs.application_load_balancer
  internal_load_balancer = data.terraform_remote_state.core_infrastructure.outputs.internal_application_load_balancer
  listener               = data.terraform_remote_state.core_infrastructure.outputs.https_listener
  internal_listener      = data.terraform_remote_state.core_infrastructure.outputs.internal_https_listener
  vpc                    = data.terraform_remote_state.core_infrastructure.outputs.vpc_hydrogen.vpc
  route53_zone           = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  internal_route53_zone  = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org
  cdn_certificate        = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  logs_bucket            = data.terraform_remote_state.core_infrastructure.outputs.logs_bucket.id
  uploads_bucket         = "uploads.somleng.org"
  audio_bucket           = "audio.somleng.org"
  db_name                = "scfm"
}

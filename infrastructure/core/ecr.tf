module "app_ecr_repository" {
  source = "../modules/ecr_repository"
  name   = "scfm"
}

module "webserver_ecr_repository" {
  source = "../modules/ecr_repository"
  name   = "scfm-webserver"
}

resource "aws_ecrpublic_repository" "app" {
  repository_name = "scfm"
  provider        = aws.us-east-1

  catalog_data {
    about_text    = "Somleng Simple Call Flow Manager (Somleng SCFM)"
    architectures = ["Linux"]
    description   = "Somleng Simple Call Flow Manager (Somleng SCFM) manages both inbound and outbound calls through Somleng and/or Twilio. Use it to create dynamic, customized and powerful call flows."
  }
}

resource "aws_ecrpublic_repository" "nginx" {
  repository_name = "scfm-nginx"
  provider        = aws.us-east-1

  catalog_data {
    about_text    = "Somleng SCFM Nginx"
    architectures = ["Linux"]
  }
}

module "app_ecr_repository" {
  source = "../modules/ecr_repository"
  name   = "scfm"
}

module "nginx_ecr_repository" {
  source = "../modules/ecr_repository"
  name   = "scfm-nginx"
}

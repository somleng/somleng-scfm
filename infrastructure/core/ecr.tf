resource "aws_ecr_repository" "app" {
  name                 = "scfm"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "nginx" {
  name                 = "scfm-nginx"

  image_scanning_configuration {
    scan_on_push = true
  }
}
